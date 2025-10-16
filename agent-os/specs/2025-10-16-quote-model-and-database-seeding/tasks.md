# Task Breakdown: Quote Model & Database Seeding

## Overview
Total Tasks: 19 (across 5 task groups)
Assigned roles: database-engineer, backend-engineer, testing-engineer

## Task List

### Phase 1: Database Foundation

#### Task Group 1: Quote Model and Migration
**Assigned implementer:** database-engineer
**Dependencies:** None

- [ ] 1.0 Complete database foundation
  - [ ] 1.1 Write 2-8 focused tests for Quote model
    - Test text presence validation
    - Test text case-insensitive uniqueness
    - Test slug uniqueness (when present)
    - Test slug auto-generation from text using parameterize
    - Test slug not overwritten if manually set
    - Limit to 5-6 highly focused tests maximum
  - [ ] 1.2 Create Quote model at `app/models/quote.rb`
    - Add validation: `validates :text, presence: true, uniqueness: { case_sensitive: false }`
    - Add validation: `validates :slug, uniqueness: true, allow_nil: true`
    - Add callback: `before_validation :generate_slug_from_text, on: :create`
    - Implement `generate_slug_from_text` private method using `text.parameterize`
    - Keep it super simple - vanilla Rails, no gems or over-engineering
  - [ ] 1.3 Create migration for quotes table
    - Table name: `quotes`
    - Add columns: id (primary key), text (string, NOT NULL), slug (string, nullable), context (text, nullable), timestamps
    - Add unique index on text column
    - Add unique index on slug column
    - Implement SQLite-specific ID sequence start at 100 (insert dummy row with ID 99, then delete)
    - Follow standard Rails migration patterns
    - Ensure migration is reversible with proper `down` method
  - [ ] 1.4 Run migration and verify schema
    - Run `rails db:migrate`
    - Verify `db/schema.rb` shows quotes table with all columns and indexes
    - Verify ID sequence starts at 100 (check sqlite_sequence table)
  - [ ] 1.5 Ensure model tests pass
    - Run ONLY the 5-6 tests written in 1.1
    - Verify all validations work correctly
    - Verify slug auto-generation works
    - Do NOT run the entire test suite at this stage

**Acceptance Criteria:**
- The 5-6 tests written in 1.1 pass
- Quote model has all required validations
- Migration creates table with correct schema and indexes
- ID sequence starts at 100
- Slugs auto-generate using parameterize method
- Migration is reversible

---

### Phase 2: Data Preparation

#### Task Group 2: Parse and Consolidate Quote Data
**Assigned implementer:** backend-engineer
**Dependencies:** Task Group 1 (model must exist to test data structure)

- [ ] 2.0 Complete data preparation
  - [ ] 2.1 Create parsing script for BuzzFeed source
    - Create rake task at `lib/tasks/parse_quotes.rake`
    - Parse `agent-os/specs/2025-10-16-quote-model-and-database-seeding/planning/visuals/quote-list-buzzfeed.md`
    - Extract 359 quotes from markdown bullet list format
    - Strip "* " prefix and whitespace
    - Output to intermediate file: `db/data/buzzfeed_quotes.txt` (one per line)
  - [ ] 2.2 Create parsing script for Fandom source
    - Add task to same rake file
    - Parse `agent-os/specs/2025-10-16-quote-model-and-database-seeding/planning/visuals/quote-list-fandom.md`
    - Extract 360 quotes from markdown bullet list format
    - Strip formatting and whitespace
    - Output to intermediate file: `db/data/fandom_quotes.txt` (one per line)
  - [ ] 2.3 Create comparison and deduplication script
    - Add rake task to compare both source files
    - Identify quotes appearing in both sources
    - Flag spelling variations (e.g., "Armour" vs "Armor", special characters)
    - Use case-insensitive comparison to find duplicates
    - Generate report showing: total unique quotes, duplicates found, spelling variations
    - Output comparison report to: `db/data/comparison_report.txt`
  - [ ] 2.4 Create consolidated master data file
    - Manually review comparison report and resolve spelling variations
    - Choose canonical spelling for each duplicate (prefer BuzzFeed spelling as source of truth)
    - Create final deduplicated list of ~359 unique quotes
    - Generate slugs for all quotes using Rails `parameterize` method
    - Check for slug collisions and resolve manually (append number if needed)
    - Assign sequential IDs starting at 100
    - Create Ruby constant file: `db/data/master_quotes.rb`
    - Format: `MASTER_QUOTES = [{id: 100, text: "Holy Holocaust", slug: "holy-holocaust", context: nil}, ...]`
    - Add header comment documenting: source files, generation date, resolution decisions, total count
  - [ ] 2.5 Verify master data integrity
    - Run simple verification script to check:
      - All IDs are sequential from 100-458 (359 quotes)
      - No duplicate IDs
      - No duplicate text values (case-insensitive)
      - No duplicate slugs
      - All text fields are present
      - All slugs are present and valid
    - Output verification summary to console

**Acceptance Criteria:**
- Both source files successfully parsed
- Comparison report identifies all duplicates and variations
- Master data file contains exactly 359 unique quotes
- IDs range from 100-458 sequentially
- All quotes have unique text and slugs
- No slug collisions exist
- Master data file is valid Ruby syntax
- Header documentation is complete

---

### Phase 3: Database Seeding

#### Task Group 3: Idempotent Seed Script
**Assigned implementer:** database-engineer
**Dependencies:** Task Group 2 (master data must exist)

- [ ] 3.0 Complete seed script implementation
  - [ ] 3.1 Write 2-4 focused integration tests for seeding
    - Test seed script runs without errors
    - Test seed script is idempotent (can run twice without duplicates)
    - Test all quotes created with correct ID range (100-458)
    - Verify Quote.count returns 359 after seeding
    - Limit to 3-4 highly focused tests maximum
  - [ ] 3.2 Implement seed script at `db/seeds.rb`
    - Load master data from `db/data/master_quotes.rb`
    - Use idempotent pattern: `Quote.find_or_initialize_by(id: data[:id])`
    - Assign attributes: text, slug, context
    - Save with `save!` to raise errors immediately
    - Display progress (e.g., "Seeding quotes... 100/359")
    - Display summary statistics at end (created count, updated count, total count)
    - Keep it super simple - no fancy progress bars or gems
  - [ ] 3.3 Test seed script execution
    - Run `rails db:seed` and verify no errors
    - Verify Quote.count returns 359
    - Verify Quote.minimum(:id) returns 100
    - Verify Quote.maximum(:id) returns 458
    - Check no duplicate text or slugs in database
  - [ ] 3.4 Test seed script idempotency
    - Run `rails db:seed` a second time
    - Verify Quote.count still returns 359 (no duplicates created)
    - Verify no errors or warnings
    - Verify all existing records updated correctly
  - [ ] 3.5 Ensure seeding tests pass
    - Run ONLY the 3-4 tests written in 3.1
    - Verify seed script works in test environment
    - Do NOT run the entire test suite at this stage

**Acceptance Criteria:**
- The 3-4 tests written in 3.1 pass
- Seed script runs successfully without errors
- All 359 quotes created with IDs 100-458
- Running seed twice does not create duplicates
- Progress and summary displayed clearly
- Database constraints enforced (no duplicate text/slugs)

---

### Phase 4: Verification & Documentation

#### Task Group 4: End-to-End Testing and Gap Analysis
**Assigned implementer:** testing-engineer
**Dependencies:** Task Groups 1-3

- [ ] 4.0 Review tests and verify complete workflow
  - [ ] 4.1 Review existing tests from previous task groups
    - Review 5-6 model tests from Task 1.1
    - Review 3-4 seeding tests from Task 3.1
    - Total existing tests: approximately 8-10 tests
  - [ ] 4.2 Analyze test coverage gaps for this feature only
    - Identify any critical workflows missing test coverage
    - Focus on database-level uniqueness constraints
    - Focus on edge cases in slug generation (special characters, duplicates)
    - Do NOT assess entire application test coverage
    - Prioritize end-to-end verification over unit test gaps
  - [ ] 4.3 Write up to 5 additional strategic tests maximum
    - Test database-level uniqueness constraint for text (case-insensitive)
    - Test database-level uniqueness constraint for slug
    - Test slug generation with special characters
    - Test that IDs persist correctly across seed runs
    - Maximum 5 new tests to fill critical gaps only
  - [ ] 4.4 Run complete feature test suite
    - Run ALL tests related to Quote model and seeding (tests from 1.1, 3.1, and 4.3)
    - Expected total: approximately 13-15 tests maximum
    - Verify all tests pass
    - Do NOT run the entire application test suite
  - [ ] 4.5 Perform manual verification
    - Reset database: `rails db:reset`
    - Run seed: `rails db:seed`
    - Open Rails console and verify:
      - `Quote.count` returns 359
      - `Quote.minimum(:id)` returns 100
      - `Quote.maximum(:id)` returns 458
      - `Quote.find(100)` returns first quote
      - `Quote.find_by(text: "Holy Holocaust")` works
      - `Quote.find_by(slug: "holy-holocaust")` works
    - Test attempting to create duplicate quote fails validation
    - Run seed again and verify idempotency

**Acceptance Criteria:**
- All feature-specific tests pass (approximately 13-15 tests total)
- No more than 5 additional tests added by testing-engineer
- Manual verification checklist completed successfully
- Database constraints enforced correctly
- Seed script confirmed idempotent
- All success criteria from spec.md verified

---

### Phase 5: Final Documentation

#### Task Group 5: Documentation and Cleanup
**Assigned implementer:** backend-engineer
**Dependencies:** Task Group 4

- [ ] 5.0 Complete documentation and cleanup
  - [ ] 5.1 Document data preparation process
    - Create `db/data/README.md` explaining:
      - Source files location
      - Data preparation workflow
      - How to regenerate master_quotes.rb if sources change
      - Spelling resolution decisions made
      - ID range allocation (100-458)
  - [ ] 5.2 Add code comments to seed script
    - Add comments explaining idempotency pattern
    - Document expected behavior (359 quotes, IDs 100-458)
    - Note that context field intentionally left nil for v1
  - [ ] 5.3 Clean up intermediate files
    - Keep: `db/data/master_quotes.rb` (required for seeding)
    - Keep: `db/data/README.md` (documentation)
    - Keep: `lib/tasks/parse_quotes.rake` (for future regeneration)
    - Optional: Archive or remove intermediate files (buzzfeed_quotes.txt, fandom_quotes.txt, comparison_report.txt)
  - [ ] 5.4 Create implementation summary
    - Document final statistics in spec folder
    - Create `agent-os/specs/2025-10-16-quote-model-and-database-seeding/implementation/summary.md`
    - Include: total quotes, ID range, test count, any issues encountered, decisions made
  - [ ] 5.5 Verify all success criteria met
    - Review all success criteria from spec.md
    - Verify each criterion is satisfied
    - Document any deviations or notes

**Acceptance Criteria:**
- README documentation complete and clear
- Code comments added to key files
- Unnecessary intermediate files cleaned up
- Implementation summary created
- All success criteria from spec.md verified and documented

---

## Execution Order

Recommended implementation sequence:
1. **Phase 1: Database Foundation** (Task Group 1) - Create model and migration
2. **Phase 2: Data Preparation** (Task Group 2) - Parse sources and create master data
3. **Phase 3: Database Seeding** (Task Group 3) - Implement idempotent seed script
4. **Phase 4: Verification & Documentation** (Task Group 4) - Test gaps and verify
5. **Phase 5: Final Documentation** (Task Group 5) - Document and cleanup

## Notes

### Testing Philosophy
- Each implementer writes 2-8 focused tests for their components
- Testing-engineer adds maximum 5 strategic tests to fill gaps
- Total expected tests: 13-15 tests maximum for entire feature
- Focus on critical paths, not exhaustive coverage
- Tests verify behavior at logical completion points

### Super Simple Philosophy
- Vanilla Rails patterns only - no gems or over-engineering
- Use standard ActiveRecord validations and callbacks
- Simple rake tasks for data preparation
- Standard seed script pattern with find_or_initialize_by
- No fancy progress bars or external dependencies

### Data Preparation Notes
- This is a ONE-TIME data preparation task (Task Group 2)
- Parse both sources, compare, deduplicate, resolve conflicts
- Create master_quotes.rb as the canonical source
- Seed script reads from master_quotes.rb (repeatable)
- If sources change in future, re-run data preparation workflow

### Idempotency Pattern
- Use explicit IDs (100-458) in master data
- Use `find_or_initialize_by(id:)` in seed script
- Allows safe re-seeding without duplicates
- Updates existing quotes if attributes change
- Critical for development and deployment workflows

### Compliance with Standards
- **Models**: Follow standard Rails model conventions with clear validations
- **Migrations**: Keep migrations reversible and focused on single logical change
- **Testing**: Write minimal tests during development (2-8 per task group), focus on core behaviors
- **Database**: Use timestamps, NOT NULL constraints, proper indexes for data integrity
- **Validation**: Validate at both model and database levels for defense in depth
- **Conventions**: Keep code simple, use descriptive names, avoid over-engineering
