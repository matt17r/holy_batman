# frozen_string_literal: true

namespace :quotes do
  desc 'Analyze and compare quote sources, create master list'
  task analyze: :environment do
    puts "\n" + "=" * 80
    puts "QUOTE DATA ANALYSIS"
    puts "=" * 80

    # Task 2.1: Parse BuzzFeed quote list
    puts "\n--- Task 2.1: Parsing BuzzFeed Quote List ---"
    buzzfeed_file = Rails.root.join('agent-os/specs/2025-10-16-quote-model-and-database-seeding/planning/visuals/quote-list-buzzfeed.md')
    buzzfeed_content = File.read(buzzfeed_file)

    # Extract quotes, removing markdown bullets and cleaning text
    buzzfeed_quotes = buzzfeed_content.split("\n").map do |line|
      line.strip.gsub(/^\*\s+/, '').gsub(/<\/p>$/, '').strip
    end.reject(&:empty?)

    puts "BuzzFeed quotes extracted: #{buzzfeed_quotes.count}"
    puts "Expected: 359"
    puts "Match: #{buzzfeed_quotes.count == 359 ? 'YES' : 'NO'}"

    # Task 2.2: Parse Fandom quote list
    puts "\n--- Task 2.2: Parsing Fandom Quote List ---"
    fandom_file = Rails.root.join('agent-os/specs/2025-10-16-quote-model-and-database-seeding/planning/visuals/quote-list-fandom.md')
    fandom_content = File.read(fandom_file)

    # Extract quotes, removing markdown bullets
    fandom_quotes = fandom_content.split("\n").map do |line|
      line.strip.gsub(/^Holy\s/, 'Holy ')
    end.reject(&:empty?)

    puts "Fandom quotes extracted: #{fandom_quotes.count}"
    puts "Expected: 360"
    puts "Match: #{fandom_quotes.count == 360 ? 'YES' : 'NO'}"

    # Task 2.3: Compare both lists and identify discrepancies
    puts "\n--- Task 2.3: Comparing Lists and Identifying Discrepancies ---"

    # Sort BuzzFeed list alphabetically
    buzzfeed_sorted = buzzfeed_quotes.sort

    # Normalize for comparison (case-insensitive)
    buzzfeed_normalized = buzzfeed_quotes.map(&:downcase).to_set
    fandom_normalized = fandom_quotes.map(&:downcase).to_set

    # Find quotes only in BuzzFeed
    only_in_buzzfeed = buzzfeed_quotes.reject { |q| fandom_normalized.include?(q.downcase) }
    puts "\nQuotes ONLY in BuzzFeed (#{only_in_buzzfeed.count}):"
    only_in_buzzfeed.sort.each { |q| puts "  - #{q}" }

    # Find quotes only in Fandom
    only_in_fandom = fandom_quotes.reject { |q| buzzfeed_normalized.include?(q.downcase) }
    puts "\nQuotes ONLY in Fandom (#{only_in_fandom.count}):"
    only_in_fandom.sort.each { |q| puts "  - #{q}" }

    # Identify text variations
    puts "\n--- Identifying Text Variations ---"
    variations = []

    # Check for near-matches (same length, similar content)
    only_in_buzzfeed.each do |bq|
      only_in_fandom.each do |fq|
        # Check if they're similar (simple heuristic: same first 10 chars)
        if bq.downcase[0..10] == fq.downcase[0..10] && bq.downcase != fq.downcase
          variations << { buzzfeed: bq, fandom: fq }
        end
      end
    end

    if variations.any?
      puts "\nPotential text variations found (#{variations.count}):"
      variations.each do |v|
        puts "  BuzzFeed: #{v[:buzzfeed]}"
        puts "  Fandom:   #{v[:fandom]}"
        puts ""
      end
    else
      puts "\nNo obvious text variations detected between similar quotes."
    end

    # Task 2.4: Create deduplicated master quote list
    puts "\n--- Task 2.4: Creating Deduplicated Master Quote List ---"

    # Combine and deduplicate (case-insensitive)
    all_quotes = (buzzfeed_quotes + fandom_quotes).uniq { |q| q.downcase }
    puts "Combined unique quotes: #{all_quotes.count}"

    # Sort alphabetically for consistent ordering
    all_quotes_sorted = all_quotes.sort_by(&:downcase)

    # Generate master list with IDs, slugs, and check for duplicates
    master_list = []
    slug_tracker = {}
    slug_duplicates = []

    all_quotes_sorted.each_with_index do |text, index|
      id = 100 + index
      slug = text.parameterize

      # Track slug duplicates
      if slug_tracker[slug]
        slug_duplicates << {
          slug: slug,
          texts: [slug_tracker[slug], text]
        }
      else
        slug_tracker[slug] = text
      end

      master_list << {
        id: id,
        text: text,
        slug: slug,
        context: nil
      }
    end

    puts "Master list created with #{master_list.count} quotes"
    puts "ID range: #{master_list.first[:id]} to #{master_list.last[:id]}"

    # Check for slug duplicates
    if slug_duplicates.any?
      puts "\n⚠️  SLUG DUPLICATES FOUND (#{slug_duplicates.count}):"
      slug_duplicates.uniq { |d| d[:slug] }.each do |dup|
        puts "\n  Slug: '#{dup[:slug]}'"
        puts "  Texts:"
        dup[:texts].each { |t| puts "    - #{t}" }
      end
      puts "\nThese will need manual resolution before seeding."
    else
      puts "\n✓ No slug duplicates found!"
    end

    # Save master list to a Ruby file
    output_file = Rails.root.join('db/data/master_quotes.rb')
    FileUtils.mkdir_p(File.dirname(output_file))

    File.open(output_file, 'w') do |f|
      f.puts "# frozen_string_literal: true"
      f.puts ""
      f.puts "# Master quote list generated from BuzzFeed and Fandom sources"
      f.puts "# Generated on: #{Time.current}"
      f.puts "# Total quotes: #{master_list.count}"
      f.puts "# ID range: #{master_list.first[:id]}-#{master_list.last[:id]}"
      f.puts ""
      f.puts "MASTER_QUOTES = ["

      master_list.each do |quote|
        f.puts "  {"
        f.puts "    id: #{quote[:id]},"
        f.puts "    text: #{quote[:text].inspect},"
        f.puts "    slug: #{quote[:slug].inspect},"
        f.puts "    context: nil"
        f.puts "  },"
      end

      f.puts "].freeze"
    end

    puts "\n✓ Master list saved to: #{output_file}"

    # Summary
    puts "\n" + "=" * 80
    puts "ANALYSIS COMPLETE - SUMMARY"
    puts "=" * 80
    puts "BuzzFeed quotes: #{buzzfeed_quotes.count}"
    puts "Fandom quotes: #{fandom_quotes.count}"
    puts "Combined unique quotes: #{all_quotes.count}"
    puts "Master list entries: #{master_list.count}"
    puts "ID range: #{master_list.first[:id]}-#{master_list.last[:id]}"
    puts "Slug duplicates: #{slug_duplicates.any? ? slug_duplicates.uniq { |d| d[:slug] }.count : 0}"
    puts "=" * 80 + "\n"
  end
end
