# Task Breakdown: Quote Model & Database Seeding

## Overview
Total Tasks: 19 sub-tasks across 4 major task groups
Feature: Simple Quote model with database seeding from markdown sources

## Task List

### Database Layer

#### Task Group 1: Quote Model and Migration
**Assigned implementer:** backend-engineer / database-engineer
**Dependencies:** None

- [ ] 1.0 Complete database layer for Quote model
  - [ ] 1.1 Write 2-8 focused tests for Quote model functionality
    - Limit to 2-8 highly focused tests maximum
    - Test only critical model behaviors:
      - Text presence validation
      - Text uniqueness (case-insensitive)
      - Slug uniqueness when present
      - Slug auto-generation from text
    - Skip exhaustive coverage of all methods and edge cases
  - [ ] 1.2 Create Quote model with validations
    - File: `app/models/quote.rb`
    - Fields:
      - `id` (integer, primary key, starting at 100)
      - `text` (string, required)
      - `slug` (string, optional)
      - `context` (text, optional)
      - `created_at`, `updated_at` (timestamps)
    - Validations:
      - `validates :text, presence: true, uniqueness: { case_sensitive: false }`
      - `validates :slug, uniqueness: true, allow_nil: true`
      - `before_validation :generate_slug_from_text, on: :create` (if slug is blank)
    - Slug generation logic:
      - Use `text.parameterize` to generate slug
      - Example: "Holy Holocaust" becomes "holy-holocaust"
  - [ ] 1.3 Create migration for quotes table
    - File: `db/migrate/YYYYMMDDHHMMSS_create_quotes.rb`
    - Create quotes table with all columns
    - Add unique index on text (case-insensitive)
    - Add unique index on slug
    - Set starting ID to 100 using SQLite approach:
      ```ruby
      # Option 1: Insert and delete dummy record
      execute "INSERT INTO quotes (id, text, created_at, updated_at) VALUES (99, 'dummy', datetime('now'), datetime('now'))"
      execute "DELETE FROM quotes WHERE id = 99"

      # Option 2: Set sqlite_sequence directly (after table creation)
      execute "INSERT INTO sqlite_sequence (name, seq) VALUES ('quotes', 99)"
      ```
  - [ ] 1.4 Run migration
    - Execute `rails db:migrate`
    - Verify quotes table created successfully
    - Verify starting ID is set to 100
  - [ ] 1.5 Ensure database layer tests pass
    - Run ONLY the 2-8 tests written in 1.1
    - Verify migrations run successfully
    - Do NOT run the entire test suite at this stage

**Acceptance Criteria:**
- The 2-8 tests written in 1.1 pass
- Quote model exists with all required validations
- Migration successfully creates quotes table
- ID sequence starts at 100
- Text uniqueness is case-insensitive
- Slug uniqueness enforced when present

### Data Parsing & Comparison

#### Task Group 2: Quote Data Analysis
**Assigned implementer:** backend-engineer / data-engineer
**Dependencies:** None (can run in parallel with Task Group 1)

- [ ] 2.0 Analyze and compare quote sources
  - [ ] 2.1 Parse BuzzFeed quote list
    - Read file: `agent-os/specs/2025-10-16-quote-model-and-database-seeding/planning/visuals/quote-list-buzzfeed.md`
    - Extract clean quote text (remove markdown bullets and BuzzFeed article numbers)
    - Store in array for comparison
    - Count: should be 359 quotes
  - [ ] 2.2 Parse Fandom quote list
    - Read file: `agent-os/specs/2025-10-16-quote-model-and-database-seeding/planning/visuals/quote-list-fandom.md`
    - Extract clean quote text (remove markdown bullets)
    - Store in array for comparison
    - Count: should be 360 quotes
  - [ ] 2.3 Compare both lists and identify discrepancies
    - Sort BuzzFeed list alphabetically for comparison
    - Compare with Fandom list (already alphabetical)
    - Identify:
      - Quotes in BuzzFeed but not in Fandom
      - Quotes in Fandom but not in BuzzFeed
      - Text variations between sources (e.g., "Armour Plate" vs "Armor Plate")
    - Document discrepancies in output/comments
  - [ ] 2.4 Create deduplicated master quote list
    - Manually resolve any critical discrepancies if needed
    - Generate slugs for each quote using parameterize
    - Check for slug duplicates and flag them for manual resolution
    - Create array with structure: `{ id: 100, text: "Holy Holocaust", slug: "holy-holocaust", context: nil }`
    - Assign sequential IDs starting at 100

**Acceptance Criteria:**
- Both quote lists successfully parsed
- Discrepancies between sources identified and documented
- Deduplicated master list created
- All quotes have sequential IDs from 100-458(ish)
- Slugs auto-generated for all quotes
- Any slug duplicates flagged for manual resolution

### Database Seeding

#### Task Group 3: Seed Script Implementation
**Assigned implementer:** backend-engineer
**Dependencies:** Task Groups 1 and 2

- [ ] 3.0 Implement idempotent seed script
  - [ ] 3.1 Create seed script in `db/seeds.rb`
    - Integrate quote data from Task Group 2
    - Use `find_or_initialize_by(id: X)` pattern for idempotency:
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
    - DO NOT automatically handle slug duplicates
    - Let validation errors surface if slug conflicts exist
    - Stop execution if any save fails (using `save!`)
  - [ ] 3.2 Test seed script idempotency
    - Run `rails db:seed` first time
    - Verify all 359 quotes created
    - Verify IDs range from 100-458
    - Run `rails db:seed` second time
    - Verify no duplicate quotes created
    - Verify quote count remains 359
  - [ ] 3.3 Handle any slug duplicate conflicts manually
    - If slug conflicts occur during seeding, stop
    - Manually review conflicting quotes
    - Add suffix to duplicates (e.g., "-2", "-3")
    - Update seed data with resolved slugs
    - Re-run seed script

**Acceptance Criteria:**
- Seed script successfully creates all 359 quotes
- All quotes have IDs from 100-458
- Seed script is idempotent (safe to run multiple times)
- No duplicate text or slugs in database
- All quotes have properly parameterized slugs
- Any slug conflicts resolved manually

### Testing & Verification

#### Task Group 4: Feature Verification
**Assigned implementer:** testing-engineer / backend-engineer
**Dependencies:** Task Groups 1-3

- [ ] 4.0 Verify Quote model and seeding functionality
  - [ ] 4.1 Review existing tests
    - Review the 2-8 tests written in Task 1.1
    - Verify they cover core model validations
  - [ ] 4.2 Run feature-specific tests
    - Run ONLY Quote model tests from Task 1.1
    - Verify all model validations work correctly
    - Do NOT run entire application test suite
  - [ ] 4.3 Write up to 5 additional verification tests if needed
    - Add maximum of 5 tests to cover any critical gaps:
      - Seed script creates correct number of quotes
      - Quotes have sequential IDs starting at 100
      - No duplicate text exists (case-insensitive)
      - No duplicate slugs exist
      - Idempotent seeding works correctly
    - Focus only on critical seeding workflows
    - Skip edge cases and error scenarios unless business-critical
  - [ ] 4.4 Verify database state
    - Check quote count: `Quote.count` should equal 359
    - Check ID range: `Quote.minimum(:id)` = 100, `Quote.maximum(:id)` = 458
    - Check uniqueness: No duplicate text or slugs
    - Verify all quotes have slugs
    - Verify all slugs are properly parameterized
  - [ ] 4.5 Run final verification
    - Run all feature-specific tests (approximately 7-13 tests total)
    - Verify database seeding is idempotent
    - Confirm all success criteria met

**Acceptance Criteria:**
- All feature-specific tests pass (approximately 7-13 tests total)
- Quote model validations work correctly
- Seed script creates exactly 359 quotes with IDs 100-458
- No duplicate text or slugs in database
- Seed script is idempotent
- All quotes have properly parameterized slugs

## Execution Order

Recommended implementation sequence:
1. **Task Group 1**: Database Layer (Quote Model and Migration)
2. **Task Group 2**: Data Parsing & Comparison (can run in parallel with Task Group 1)
3. **Task Group 3**: Database Seeding (requires both Task Groups 1 & 2)
4. **Task Group 4**: Testing & Verification (requires all previous task groups)

## Technical Notes

### Key Constraints from Requirements
- Keep implementation super simple and vanilla Rails
- No over-engineering
- Start IDs at 100 for 3-digit IDs
- Idempotent seeding using explicit IDs
- Parse quotes from two markdown sources and compare
- Handle slug duplicates manually during seeding
- Text uniqueness is case-insensitive
- Slug uniqueness when present (allow nil)

### Compliance with Standards
- **Models**: Follow standard Rails model conventions with clear validations
- **Migrations**: Keep migrations reversible and focused on single logical change
- **Testing**: Write minimal tests during development (2-8 per task group), focus on core behaviors
- **Conventions**: Use environment variables if needed, never commit secrets
- **Database**: Use timestamps, NOT NULL constraints, and proper indexes

### Out of Scope
- Admin interface for managing quotes
- API endpoints (separate spec)
- Search functionality
- Soft deletes or versioning
- Edit history or audit trail
- Character name field
- Episode metadata (season, air date, etc.)
- Popularity ratings or view counts
- Tags or categories
- Authentication or authorization
- Front-end views (separate spec)
