# frozen_string_literal: true

# Load master quotes data
require_relative 'data/master_quotes'

puts "Seeding quotes database..."
puts "Loading #{MASTER_QUOTES.count} quotes from master data..."

# Use idempotent pattern: find_or_initialize_by with explicit ID
MASTER_QUOTES.each do |data|
  quote = Quote.find_or_initialize_by(id: data[:id])
  quote.assign_attributes(
    text: data[:text],
    slug: data[:slug],
    context: data[:context]
  )
  quote.save!
end

puts "Seeding complete!"
puts "Total quotes in database: #{Quote.count}"
puts "ID range: #{Quote.minimum(:id)} - #{Quote.maximum(:id)}"
