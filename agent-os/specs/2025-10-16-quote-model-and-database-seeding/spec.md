# Specification: Quote Model & Database Seeding

## Goal
Create a simple Quote model to store Robin's iconic "Holy ___" exclamations from the 1960s Batman TV series, then seed the database with ~360 quotes sourced from two markdown files. Keep it vanilla Rails with no over-engineering.

## User Stories
- As a developer, I want to store quotes in a database so that the application can retrieve and display them
- As a developer, I want each quote to have a unique 3-digit ID starting at 100 so that permalinks are clean and consistent
- As a developer, I want to run the seed script multiple times without creating duplicates so that database seeding is idempotent
- As a developer, I want slugs auto-generated from quote text so that URLs can be human-readable in the future
- As a future developer, I want an optional context field so that I can add easter egg content similar to XKCD comics

## Core Requirements

### Functional Requirements
- Quote model with fields: id (starting at 100), text (required), slug (optional), context (optional), timestamps
- Text must be unique (case-insensitive) across all quotes
- Slug must be unique when present
- Extract ~360 quotes from buzzfeed and fandom markdown files
- Auto-generate slugs from quote text using parameterization
- Assign sequential IDs starting at 100 (quotes will have IDs 100-459(ish))
- Seed script must be idempotent using explicit ID assignment
- Permalink pattern: `/:id` (e.g., /100, /101, /102)

### Non-Functional Requirements
- Keep implementation super simple and vanilla Rails
- No admin interface, soft deletes, versioning, or edit history
- Use standard Rails conventions for model, migration, and seed files
- Seed script should be safe to run multiple times without errors

## Visual Design
- No visual design needed for this spec (data model only)
- Visual assets provided:
  - `planning/visuals/quote-list-buzzfeed.md` containing 359 quotes
  - `planning/visuals/quote-list-fandom.md` containing 360 quotes

## Reusable Components

### Existing Code to Leverage
- ApplicationRecord base class at `app/models/application_record.rb`
- Standard Rails migration patterns (no existing migrations to reference)
- Standard Rails seed patterns at `db/seeds.rb` (currently empty with example commented out)
- SQLite3 database configuration at `config/database.yml`

### New Components Required
- Quote model (doesn't exist yet)
- Create quotes migration (first migration in the app)
- Seed script logic to parse HTML and populate quotes

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
- Unique index on text (case-insensitive)
- Unique index on slug (when present)

### Model Validations
File: `app/models/quote.rb`

Validations:
- `validates :text, presence: true, uniqueness: { case_sensitive: false }`
- `validates :slug, uniqueness: true, allow_nil: true`
- `before_validation :generate_slug_from_text, on: :create` (if slug is blank)

Slug generation logic:
- Parameterize the text field: `text.parameterize`
- Example: "Holy Holocaust" becomes "holy-holocaust"
- Handle duplicates manually during seeding (add suffix like "-2", "-3" if needed)

### Migration Details
File: `db/migrate/YYYYMMDDHHMMSS_create_quotes.rb`

Key migration steps:
1. Create quotes table with all columns
2. Add unique index on text with case-insensitive collation
3. Add unique index on slug
4. Starting ID not required as we'll explicitly set IDs and SQLite will continue on with next available ID if more are added in the future.

### Seed Script Approach
File: `db/seeds.rb`

High-level algorithm:
1. Read markdown files from `agent-os/specs/2025-10-16-quote-model-and-database-seeding/planning/visuals/quote-list-buzzfeed.md` and `agent-os/specs/2025-10-16-quote-model-and-database-seeding/planning/visuals/quote-list-fandom.md`
2. Sort the buzzfeed list alphabetically
3. Compare the two lists and highlight any discrepancies
4. Extract clean deduplicated quote text
5. Generate slug from each quote text
6. Build array of quote data with explicit IDs starting at 100
7. Use `find_or_initialize_by(id: X)` to ensure idempotency
8. Update attributes and save
9. If any conflicts prevent saving, stop and let me tidy them up

Idempotency pattern:
```ruby
quotes_data.each do |data|
  quote = Quote.find_or_initialize_by(id: data[:id])
  quote.assign_attributes(
    text: data[:text],
    slug: data[:slug],
    context: data[:context]
  )
  quote.save!
end
```

Slug duplicate handling:
- During development of seed script, **DO NOT** check for duplicate slugs

### Testing Strategy
- Model validations should be tested (presence, uniqueness)
- Seed script should be runnable multiple times without errors
- Verify all quotes are created with IDs 100-459(ish)
- Verify no duplicate text or slugs exist after seeding
- Test that running seed script twice doesn't create duplicate quotes

## Out of Scope
- Admin interface for managing quotes
- API endpoints for quotes (will be added later)
- Search functionality
- Soft deletes or versioning
- Edit history or audit trail
- Character name field (only Robin quotes for v1)
- Episode number, season, or air date metadata
- Popularity ratings or view counts
- Tags or categories
- Authentication or authorization
- Front-end views (separate spec)

## Success Criteria
- Quote model exists with all specified fields and validations
- Migration successfully creates quotes table with ID starting at 100
- Seed script parses HTML and creates exactly 359 quotes
- All quotes have IDs from 100 to 458
- All quotes have unique text (case-insensitive)
- All quotes have unique slugs (or null)
- Running `rails db:seed` multiple times is safe and idempotent
- No BuzzFeed article numbers are stored in the database
- Slugs are properly parameterized (e.g., "holy-holocaust", "holy-banks")
