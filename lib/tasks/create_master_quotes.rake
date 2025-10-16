# frozen_string_literal: true

namespace :quotes do
  desc 'Create final deduplicated master quote list with manual resolutions'
  task create_master: :environment do
    puts "\n" + "=" * 80
    puts "CREATING FINAL MASTER QUOTE LIST"
    puts "=" * 80

    # Parse both sources
    buzzfeed_file = Rails.root.join('agent-os/specs/2025-10-16-quote-model-and-database-seeding/planning/visuals/quote-list-buzzfeed.md')
    buzzfeed_content = File.read(buzzfeed_file)
    buzzfeed_quotes = buzzfeed_content.split("\n").map do |line|
      line.strip.gsub(/^\*\s+/, '').gsub(/<\/p>$/, '').strip
    end.reject(&:empty?)

    fandom_file = Rails.root.join('agent-os/specs/2025-10-16-quote-model-and-database-seeding/planning/visuals/quote-list-fandom.md')
    fandom_content = File.read(fandom_file)
    fandom_quotes = fandom_content.split("\n").map do |line|
      line.strip.gsub(/^Holy\s/, 'Holy ')
    end.reject(&:empty?)

    # Manual resolution of discrepancies
    # Use BuzzFeed version for most variations, with some exceptions
    resolution_map = {
      # Use British spelling (Armour) from Fandom
      'Holy Armor Plate' => 'Holy Armour Plate',

      # Use standard ASCII characters (no special chars)
      'Holy Chocolate Éclair' => 'Holy Chocolate Eclair',
      'Holy Cliché' => 'Holy Cliche',
      'Holy Naïve' => 'Holy Naive',

      # Use proper spelling
      'Holy Unlikelyhood' => 'Holy Unlikelihood',

      # Use possessive form
      "Holy New Years Eve" => "Holy New Year's Eve",
      "Holy Razors Edge" => "Holy Razor's Edge",
      "Holy Human Collectors Item" => "Holy Human Collector's Item",

      # Use standard spelling
      'Holy Hutzpa' => 'Holy Hutzpah',

      # Use proper punctuation
      'Holy Frankenstein Its Alive' => "Holy Frankenstein, It's Alive",

      # Use comma version
      'Holy Knit One Pearl Two' => 'Holy Knit One, Purl Two',

      # Use hyphenated versions
      'Holy Merry Go Around' => 'Holy Merry-go-round',
      'Holy Jail Break' => 'Holy Jailbreak',
      'Holy Jaw Breaker' => 'Holy Jawbreaker',
      'Holy Self Service' => 'Holy Self-Service',
      'Holy Switch A Roo' => 'Holy Switch-a-roo',
      'Holy Tipoffs' => 'Holy Tip-offs',
      'Holy Finishing-touches' => 'Holy Finishing Touches',
      'Holy Greetings-cards' => 'Holy Greetings Cards',

      # Remove duplicate from Fandom list
      'Holy Jack In The Box - 2' => nil # Skip this duplicate
    }

    # Apply resolutions
    resolved_buzzfeed = buzzfeed_quotes.map { |q| resolution_map[q] || q }.compact
    resolved_fandom = fandom_quotes.map { |q| resolution_map[q] || q }.compact

    # Combine and deduplicate
    all_quotes = (resolved_buzzfeed + resolved_fandom).uniq { |q| q.downcase }
    puts "Combined unique quotes after resolution: #{all_quotes.count}"

    # Sort alphabetically
    all_quotes_sorted = all_quotes.sort_by(&:downcase)

    # Generate master list with IDs and slugs
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
          existing: slug_tracker[slug],
          duplicate: text
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

    # Check for remaining slug duplicates
    if slug_duplicates.any?
      puts "\n⚠️  REMAINING SLUG DUPLICATES (#{slug_duplicates.count}):"
      slug_duplicates.each do |dup|
        puts "\n  Slug: '#{dup[:slug]}'"
        puts "  Existing: #{dup[:existing]}"
        puts "  Duplicate: #{dup[:duplicate]}"
      end
      puts "\nERROR: Manual resolution needed before continuing."
      exit 1
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
      f.puts "#"
      f.puts "# Resolution decisions:"
      f.puts "# - Used British spelling: 'Armour Plate' (vs 'Armor Plate')"
      f.puts "# - Used standard ASCII: 'Eclair', 'Cliche', 'Naive' (removed special chars)"
      f.puts "# - Used correct spelling: 'Unlikelihood' (vs 'Unlikelyhood')"
      f.puts "# - Used possessive forms: \"New Year's Eve\", \"Razor's Edge\", \"Collector's Item\""
      f.puts "# - Used standard spelling: 'Hutzpah' (vs 'Hutzpa')"
      f.puts "# - Used proper punctuation: \"Frankenstein, It's Alive\""
      f.puts "# - Used correct knitting term: 'Purl' (vs 'Pearl')"
      f.puts "# - Used hyphenated versions for consistency"
      f.puts "# - Removed 'Jack In The Box - 2' duplicate from Fandom list"
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
    puts "FINAL MASTER LIST SUMMARY"
    puts "=" * 80
    puts "Total quotes: #{master_list.count}"
    puts "ID range: #{master_list.first[:id]}-#{master_list.last[:id]}"
    puts "Slug duplicates: 0"
    puts "Ready for seeding: YES"
    puts "=" * 80 + "\n"
  end
end
