require "application_system_test_case"

class QuoteDisplayTest < ApplicationSystemTestCase
  test "view renders without errors when quote present" do
    visit root_path
    assert_selector "body"
    assert_no_text "error"
  end

  test "quote text is displayed on page" do
    visit root_path
    assert_selector "p.quote-text"
    assert_text /Holy/i
  end

  test "context field is present in DOM for tooltip" do
    visit root_path
    assert_selector ".quote-tooltip", visible: :hidden
  end

  test "responsive text sizing classes are applied" do
    visit root_path
    # Verify the quote text has responsive sizing classes
    assert_selector ".quote-text[class*='text-']"
  end

  # Additional integration tests for critical workflows

  test "dark background is applied to body" do
    visit root_path
    # Verify dark background class is present
    assert_selector "body.bg-gray-900"
  end

  test "comic book explosions and sound effects are visible" do
    visit root_path
    # Verify all three explosion elements are present
    assert_selector "body svg", count: 3
    # Verify sound effect words are present
    assert_text "POW!"
    assert_text "BAM!"
    assert_text "BIFF!"
  end

  test "tooltip structure is present with context label" do
    visit root_path
    # Verify tooltip element exists with the "Context:" label
    assert_selector ".quote-tooltip", text: "Context:", visible: :hidden
    # Verify tooltip has hidden class for proper hover behavior
    tooltip = find(".quote-tooltip", visible: :hidden)
    assert tooltip[:class].include?("hidden"), "Tooltip should have 'hidden' class"
    assert tooltip[:class].include?("group-hover:block"), "Tooltip should have 'group-hover:block' class"
  end

  test "multiple page visits show quote display works consistently" do
    # First visit
    visit root_path
    assert_selector "p.quote-text"
    first_quote = find("p.quote-text").text

    # Second visit (might be same quote due to randomness, but should still work)
    visit root_path
    assert_selector "p.quote-text"
    second_quote = find("p.quote-text").text

    # Both should contain "Holy" regardless of which quote
    assert_match /Holy/i, first_quote
    assert_match /Holy/i, second_quote
  end

  test "layout elements do not obscure quote text" do
    visit root_path
    # Verify quote text is visible and not covered by explosions
    quote_element = find("p.quote-text")
    assert quote_element.visible?
    # Verify main container has proper z-index layering
    assert_selector "main.z-10"
  end

  test "responsive container classes are applied to main element" do
    visit root_path
    # Verify main has flex centering and padding classes
    assert_selector "main.flex.items-center.justify-center.min-h-screen"
  end
end
