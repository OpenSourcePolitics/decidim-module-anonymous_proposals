# frozen_string_literal: true

DECIDIM_VERSION = ">= 0.29.0"

source "https://rubygems.org"

ruby RUBY_VERSION

gem "decidim", DECIDIM_VERSION
gem "decidim-anonymous_proposals", path: "."

gem "bootsnap", "~> 1.4"
gem "puma", ">= 6.3.1"
gem "uglifier", "~> 4.1"

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri

  gem "decidim-dev", DECIDIM_VERSION
end

group :development do
  gem "faker", "~> 3.2"
  gem "letter_opener_web", "~> 2.0"
  gem "listen", "~> 3.1"
  gem "spring", "~> 4.0"
  gem "spring-watcher-listen", "~> 2.1.0"
  gem "web-console", "~> 4.2"
end
