require "test_helper"

class QuoteSeedTest < ActiveSupport::TestCase
  # Load seed data once for all tests in this class
  def setup
    # Clear any existing quotes to ensure clean state
    Quote.delete_all

    # Load the seed data
    require_relative "../../db/data/master_quotes"
    MASTER_QUOTES.each do |data|
      quote = Quote.find_or_initialize_by(id: data[:id])
      quote.assign_attributes(
        text: data[:text],
        slug: data[:slug],
        context: data[:context]
      )
      quote.save!
    end
  end

  test "database should contain exactly 359 quotes" do
    assert_equal 359, Quote.count, "Expected exactly 359 quotes in database"
  end

  test "quotes should have sequential IDs starting at 100" do
    assert_equal 100, Quote.minimum(:id), "First quote ID should be 100"
    assert_equal 458, Quote.maximum(:id), "Last quote ID should be 458"
  end

  test "all quote text should be unique case-insensitive" do
    unique_text_count = Quote.select(:text).distinct.count
    total_count = Quote.count
    assert_equal total_count, unique_text_count, "All quote text should be unique"

    # Verify case-insensitive uniqueness by checking no downcased duplicates
    downcased_texts = Quote.pluck(:text).map(&:downcase)
    assert_equal downcased_texts.uniq.count, downcased_texts.count, "Text should be case-insensitively unique"
  end

  test "all slugs should be unique" do
    slugs = Quote.where.not(slug: nil).pluck(:slug)
    assert_equal slugs.uniq.count, slugs.count, "All slugs should be unique"
  end

  test "all quotes should have properly parameterized slugs" do
    assert Quote.count > 0, "Should have quotes to test"

    invalid_slugs = []
    Quote.find_each do |quote|
      # Verify slug exists
      if quote.slug.nil?
        invalid_slugs << "Quote #{quote.id} has nil slug"
        next
      end

      # Verify slug is properly parameterized (lowercase, hyphenated, no special chars)
      unless quote.slug.match?(/\A[a-z0-9-]+\z/)
        invalid_slugs << "Quote #{quote.id} slug '#{quote.slug}' contains invalid characters"
      end

      # Verify slug matches parameterized text
      expected_slug = quote.text.parameterize
      unless expected_slug == quote.slug
        invalid_slugs << "Quote #{quote.id} slug '#{quote.slug}' doesn't match expected '#{expected_slug}'"
      end
    end

    assert_empty invalid_slugs, "Found invalid slugs:\n#{invalid_slugs.join("\n")}"
  end
end
