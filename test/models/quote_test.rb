require "test_helper"

class QuoteTest < ActiveSupport::TestCase
  test "should not save quote without text" do
    quote = Quote.new
    assert_not quote.save, "Saved quote without text"
  end

  test "should enforce case-insensitive uniqueness on text" do
    Quote.create!(text: "Holy Holocaust")
    duplicate = Quote.new(text: "holy holocaust")
    assert_not duplicate.save, "Saved duplicate quote with different case"
  end

  test "should enforce slug uniqueness when present" do
    Quote.create!(text: "Holy Banks", slug: "holy-banks")
    duplicate = Quote.new(text: "Holy Different Text", slug: "holy-banks")
    assert_not duplicate.save, "Saved quote with duplicate slug"
  end

  test "should allow nil slug values" do
    quote1 = Quote.create!(text: "Holy First", slug: nil)
    quote2 = Quote.create!(text: "Holy Second", slug: nil)
    assert quote1.persisted?, "First quote with nil slug should save"
    assert quote2.persisted?, "Second quote with nil slug should save"
  end

  test "should auto-generate slug from text on create" do
    quote = Quote.create!(text: "Holy Holocaust")
    assert_equal "holy-holocaust", quote.slug
  end

  test "should not override manually set slug" do
    quote = Quote.create!(text: "Holy Banks", slug: "custom-slug")
    assert_equal "custom-slug", quote.slug
  end

  test "should parameterize slug correctly" do
    quote = Quote.create!(text: "Holy Smokes & Fire!")
    assert_equal "holy-smokes-fire", quote.slug
  end

  test "should not generate slug on update" do
    quote = Quote.create!(text: "Holy Holocaust")
    original_slug = quote.slug
    quote.update!(text: "Holy Different Text")
    assert_equal original_slug, quote.slug
  end
end
