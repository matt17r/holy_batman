class Quote < ApplicationRecord
  validates :text, presence: true, uniqueness: { case_sensitive: false }
  validates :slug, uniqueness: true, allow_nil: true

  before_validation :generate_slug_from_text, on: :create

  private

  def generate_slug_from_text
    self.slug = text.parameterize if slug.blank? && text.present?
  end
end
