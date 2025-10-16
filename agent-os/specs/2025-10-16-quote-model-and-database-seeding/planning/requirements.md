# Spec Requirements: Quote Model & Database Seeding

## Initial Description
**Quote Model & Database Seeding** - Create Quote model with fields for text and context, then seed the database with a comprehensive collection of Robin's iconic "Holy ___" exclamations from the 1960s Batman TV series. Include validation and ensure quotes are unique.

## Requirements Discussion

### First Round Questions

**Q1: Quote Model Schema - context field**
I assume the `context` field should be optional and allow storing additional information about each quote (like the episode or situation). Is that correct, or should it be required?

**Answer:** An optional context field could be good, maybe later we can use it as an alt text easter egg field like XKCD comics do

**Q2: Slug generation**
I'm thinking we should auto-generate slugs from the quote text (e.g., "Holy Holocaust" becomes "holy-holocaust"). Should we allow custom slugs, or always auto-generate? Also, for the permalink pattern, should it be `/:slug` or `/:id`?

**Answer:** A custom slug should be optional, initially I just want the permalink to be `/:id` (and maybe we'll start the IDs at 100 so they're all 3 digits). Do your best to populate the custom slugs the way you described. But make sure uniqueness is enforced so if there are any duplicates we have to fix them before seeding the database.

**Q3: Character names**
Should we include a field for which character said the quote, or are we only focusing on Robin's quotes for v1?

**Answer:** Correct, no character names in v1

**Q4: Validation constraints**
For the text field, should we enforce any length limits (min/max), or just require presence and uniqueness? Should uniqueness be case-sensitive or case-insensitive?

**Answer:** No additional constraints beyond the ones you've described (text present and unique case-insensitive, slug unique) are necessary

**Q5: Slug uniqueness handling**
When auto-generating slugs, if we get a duplicate (e.g., two quotes that would both generate "holy-catastrophe"), should we append a number (holy-catastrophe-2), or handle it differently?

**Answer:** Handle optional slug uniqueness manually during seeding

**Q6: Quote data format**
What format is the comprehensive collection of quotes in? Is it a CSV, JSON, plain text file, or something else? Where is it located?

**Answer:** The quotes are in `agent-os/specs/2025-10-16-quote-model-and-database-seeding/planning/visuals/quote-list-buzzfeed.md` and `agent-os/specs/2025-10-16-quote-model-and-database-seeding/planning/visuals/quote-list-fandom.md` - Format is markdown list

**Q7: Seed idempotency**
Should the seed script be idempotent (safe to run multiple times without creating duplicates)? If yes, should we use `find_or_create_by` or clear and recreate?

**Answer:** Can we specify IDs in the seed file? Starting at 100 so all quotes are 3 digits? Then use that for idempotency

**Q8: Additional fields**
Are there any other fields we should include? For example:
- Episode number or season?
- Year or air date?
- Popularity rating?
- Tags or categories?

**Answer:** Nope, no other fields; keep v1 simple!!!

**Q9: What to exclude**
Is there anything explicitly NOT needed for v1? For example:
- Admin interface for managing quotes?
- API endpoints?
- Search functionality?
- Soft deletes or versioning?

**Answer:** Yes, anything not mentioned already should be excluded. Keep it super simple. Soft deletes, versioning, editing, etc are not required. There is no admin interface needed. Keep it super simple. Oh, and keep it super simple!

### Existing Code to Reference

**Similar Features Identified:**
No similar existing features identified - this is a brand new app. Keep it super simple and vanilla Rails.

## Visual Assets

### Files Provided:
- `quote-list-buzzfeed.md`: Markdown document containing 359 "Holy ___" quotes in "ranked" order (descending)
- `quote-list-fandom.md`: Markdown document containing 360 "Holy ___" quotes in alphabetical order
- `XKCD.png`: shows the XKCD layout including:
  - prev, random and next buttons
  - alt text containing easter egg
  - permalink

### Visual Insights:
- Data sources are Markdown List
- Two sources allows for comparison and confirmation

## Requirements Summary

### Functional Requirements
- Create a Quote model with the following fields:
  - `id` (integer, primary key, starting at 100)
  - `text` (string, required, case-insensitive unique)
  - `slug` (string, optional, unique if present)
  - `context` (text, optional, for future use as easter egg content)
  - `created_at` and `updated_at` (timestamps)
- Analyse both data sources to confirm quotes
- Auto-generate slugs from quote text (parameterized)
- Handle slug duplicate conflicts manually during seeding
- Seed database with specific IDs starting at 100 (100-458) for idempotency
- Permalink pattern: `/:id` (e.g., /100, /101, /102)

### Non-Functional Requirements
- Keep implementation super simple and vanilla Rails
- No over-engineering
- Seed script must be idempotent (safe to run multiple times)
- All quote IDs should be 3 digits (100+)

### Reusability Opportunities
None - this is a brand new Rails application with no existing patterns to reference.

### Scope Boundaries

**In Scope:**
- Quote model with id, text, slug, context, timestamps
- Model validations (text presence and case-insensitive uniqueness, slug uniqueness)
- Migration to create quotes table with id starting at 100
- Seed script to parse HTML and populate database
- Auto-generate slugs from quote text
- Manual duplicate slug handling during seeding
- Idempotent seeding using explicit IDs

**Out of Scope:**
- Character name field
- Admin interface
- API endpoints
- Search functionality
- Soft deletes
- Versioning
- Edit history
- Length validation on text
- Episode or air date metadata
- Popularity ratings
- Tags or categories
- Authentication or authorization
- Front-end views (not part of this spec)

### Technical Considerations
- Use vanilla Rails conventions
- Start quote IDs at 100 to ensure all are 3 digits
- Use case-insensitive uniqueness validation for quote text
- Extract quotes from `agent-os/specs/2025-10-16-quote-model-and-database-seeding/planning/visuals/quote-list-buzzfeed.md` and `agent-os/specs/2025-10-16-quote-model-and-database-seeding/planning/visuals/quote-list-fandom.md`
- Confirm/deduplicate quotes using the two collections
- Shuffle the collection and then assign sequential IDs starting at 100
- Specify explicit IDs in seed data for idempotency
- Use `find_or_initialize_by(id:)` or similar for idempotent seeding
- Handle slug generation collisions manually during seed data preparation
- Keep it SUPER SIMPLE - no over-engineering!
