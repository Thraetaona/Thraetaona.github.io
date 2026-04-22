source "https://rubygems.org"

# Jekyll and plugins
gem "jekyll", "~> 4.3.4"
gem "jekyll-paginate"
gem "jekyll-feed"
gem "jekyll-sitemap"
# Uncomment the line below if you want to use AsciiDoc
# gem "jekyll-asciidoc"
gem "webrick", "~> 1.8"  # Required for Ruby 3+
gem "minima"

# Windows and JRuby does not include zoneinfo files, so bundle the tzinfo-data gem
# and associated library.
platforms :mingw, :x64_mingw, :mswin, :jruby do
  gem "tzinfo", ">= 1", "< 3"
  gem "tzinfo-data"
end

# Performance-booster for watching directories on Windows
# Only install wdm if we're on Windows and have the required dev tools
# Otherwise, it will be skipped
if Gem.win_platform?
  begin
    require 'wdm'
    gem "wdm", "~> 0.1.1"
  rescue LoadError
    # wdm cannot be installed - most likely missing development tools
    puts "wdm gem cannot be loaded, skipping (you may need to install development tools)"
  end
end

gem "http_parser.rb", "~> 0.6.0", :platforms => [:jruby]