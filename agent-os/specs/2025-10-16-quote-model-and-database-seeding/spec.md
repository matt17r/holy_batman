# Specification: Quote Model & Database Seeding

## Goal
Create a Quote model to store Robin's iconic "Holy ___" exclamations from the 1960s Batman TV series and seed the database with a comprehensive collection of ~360 quotes parsed from two markdown source files. Keep it super simple - vanilla Rails with no over-engineering.

## User Stories
- As a Batman fan, I want to browse Robin's iconic "Holy" quotes so that I can relive memorable moments from the classic TV series
- As a developer, I want quotes to have unique, predictable 3-digit IDs starting at 100 so that permalinks remain stable across environments
- As a developer, I want the seed data to be idempotent so that I can safely run it multiple times without creating duplicates
- As a developer, I want slugs auto-generated from quote text so that URLs can be human-readable in the future
- As a future developer, I want an optional context field so that I can add easter egg content similar to XKCD comics

## Core Requirements

### Functional Requirements
- Create Quote model with the following attributes:
  - id: Primary key, starting at 100 (all IDs are 3 digits: 100-458)
  - text: The quote text (required, case-insensitive unique)
  - slug: URL-friendly version of the quote (optional, unique if present)
  - context: Optional field for future easter egg content (XKCD-style alt text)
  - timestamps: Standard created_at and updated_at
- Parse quotes from two markdown source files:
  - `planning/visuals/quote-list-buzzfeed.md` (359 quotes, ranked order)
  - `planning/visuals/quote-list-fandom.md` (360 quotes, alphabetical)
- Auto-generate slugs from quote text using Rails parameterize method
- Handle slug uniqueness conflicts manually during seed data preparation
- Seed database with explicit IDs for idempotency (100-458)
- Support permalink pattern: `/:id` (e.g., /100, /101, /102)

### Non-Functional Requirements
- Keep implementation super simple - vanilla Rails, no over-engineering
- Ensure seed script is idempotent (safe to run multiple times)
- Case-insensitive uniqueness for quote text
- Slug uniqueness must be enforced at database level
- All quote IDs must be exactly 3 digits (100+)

## Visual Design

### Data Source References
- `planning/visuals/quote-list-buzzfeed.md`: Contains 359 quotes in "ranked" order (descending)
- `planning/visuals/quote-list-fandom.md`: Contains 360 quotes in alphabetical order
- `planning/visuals/XKCD.png`: Reference image showing:
  - prev, random, next button layout
  - alt text easter egg concept (for future context field use)
  - permalink pattern

### Data Characteristics
- BuzzFeed list: 359 quotes in ranked order
- Fandom list: 360 quotes alphabetically sorted
- Some quotes appear in both with spelling variations
- Need to consolidate, deduplicate, and resolve spelling differences
- Context field inspired by XKCD's hover text easter eggs (empty in v1)

## Reusable Components

### Existing Code to Leverage
- ApplicationRecord base class at `app/models/application_record.rb`
- Standard Rails migration patterns
- Standard Rails seed patterns at `db/seeds.rb`
- SQLite3 database configuration at `config/database.yml`

Note: This is a brand new Rails application with minimal existing code to reference.

### New Components Required
- Quote model: New ActiveRecord model with validations
- Migration: Create quotes table with unique indexes and ID sequencing
- Master data file: Consolidated, deduplicated quote data with explicit IDs
- Seed script: Idempotent database seeding logic

## Technical Approach

### Database Schema
Table name: `quotes`

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| id | integer | primary key, NOT NULL | Start at 100, auto-increment |
| text | string | NOT NULL, unique (case-insensitive) | The quote text, e.g., "Holy Holocaust" |
| slug | string | unique, nullable | Auto-generated from text, e.g., "holy-holocaust" |
| context | text | nullable | Optional easter egg field for future use |
| created_at | datetime | NOT NULL | Rails timestamp |
| updated_at | datetime | NOT NULL | Rails timestamp |

Indexes:
- Primary key index on id (automatic)
- Unique index on text column
- Unique index on slug column

ID Sequencing:
- Use SQLite-specific approach to set starting ID to 100
- Insert dummy row with ID 99, then delete it
- This sets the sequence counter so next insert gets ID 100

### Model Validations
File: `app/models/quote.rb`

Validations:
- `validates :text, presence: true, uniqueness: { case_sensitive: false }`
- `validates :slug, uniqueness: true, allow_nil: true`
- `before_validation :generate_slug_from_text, on: :create`

Slug generation logic:
- Auto-generate slug from text field using `text.parameterize`
- Only generate if slug is blank and text is present
- Example: "Holy Holocaust" becomes "holy-holocaust"
- Duplicate slugs must be handled manually during seed data preparation

### Migration Details
File: `db/migrate/YYYYMMDDHHMMSS_create_quotes.rb`

Migration steps:
1. Create quotes table with all columns (id, text, slug, context, timestamps)
2. Add unique index on text column
3. Add unique index on slug column
4. Execute SQL to set starting ID to 100:
   - Insert dummy row with ID 99
   - Delete the dummy row
   - Next auto-increment value will be 100

### Data Preparation Process
This happens during seed development, not at runtime:

1. Parse both markdown source files to extract quote text
2. Compare BuzzFeed and Fandom lists
3. Identify quotes in both sources
4. Resolve spelling variations (e.g., "Armor" vs "Armour", special characters)
5. Consolidate to final deduplicated list (~359 unique quotes)
6. Generate slugs using parameterize
7. Check for slug collisions and resolve manually if needed
8. Assign sequential IDs starting at 100
9. Create master data file at `db/data/master_quotes.rb`
10. Document resolution decisions in master data file header

### Seed Script Implementation
File: `db/seeds.rb`

Approach:
- Load quotes data from `db/data/master_quotes.rb` constant
- Use idempotent pattern with explicit ID assignment
- Display progress and summary statistics

Idempotency pattern:
```ruby
MASTER_QUOTES.each do |data|
  quote = Quote.find_or_initialize_by(id: data[:id])
  quote.assign_attributes(
    text: data[:text],
    slug: data[:slug],
    context: data[:context]
  )
  quote.save!
end
```

Master data file format:
- Ruby constant `MASTER_QUOTES` containing array of hashes
- Each hash has: id, text, slug, context (nil)
- Header comment documenting source, generation date, and resolution decisions
- Explicit IDs starting at 100

### Testing Strategy
Model tests:
- Test text presence validation
- Test text case-insensitive uniqueness
- Test slug uniqueness (when present)
- Test slug auto-generation from text
- Test slug not overwritten if manually set

Integration tests:
- Test seed script runs without errors
- Test seed script is idempotent (can run multiple times)
- Verify all quotes created with correct ID range (100-458)
- Verify no duplicate text or slugs after seeding

## Out of Scope
- Character name field (only Robin quotes for v1)
- Admin interface for managing quotes
- API endpoints for quotes
- Search functionality
- Soft deletes or versioning
- Edit history or audit trail
- Length validation on text field
- Episode number, season, or air date metadata
- Popularity ratings or view counts
- Tags or categories
- Authentication or authorization
- Frontend views (separate spec)
- Multiple character support
- Quote editing or updating UI

## Success Criteria
- Quote model created with all specified fields and validations
- Database migration runs successfully and sets ID sequence to 100
- Migration is reversible (can be rolled back)
- All quotes from both sources are parsed and analyzed
- Spelling variations between sources are identified and resolved
- Final master data contains 359 unique quotes (after deduplication)
- Quotes are assigned IDs 100-458 (sequential, 3 digits)
- All quotes have valid, unique slugs
- No slug conflicts exist
- Seed script loads and creates all quotes without errors
- Seed script can be run multiple times safely (idempotent)
- Running seed twice does not create duplicate quotes
- Model validations prevent duplicate quotes at application level
- Database constraints enforce uniqueness at database level
- Quote.count returns 359 after seeding
- Quote.minimum(:id) returns 100
- Quote.maximum(:id) returns 458
