#!/usr/bin/env rackup
# -*- coding: utf-8 -*-

path = ::File.expand_path(::File.dirname(__FILE__))
$: << ::File.join(path, 'lib')
Dir[::File.join(path, 'deps', '*', 'lib')].each {|x| $: << x }

require 'wiki/timer'
timer = Wiki::Timer.start

# Require newest rack
raise RuntimeError, 'Rack 1.1.0 or newer required' if Rack.version < '1.1'

require 'rubygems'

# Load ruby 1.8 compatibility gem
if RUBY_VERSION < '1.9'
  # will soon be moved to gem
  # gem 'compatibility', '>= 0'
  require 'compatibility'
end

# We want to read all text data as UTF-8
Encoding.default_external = Encoding::UTF_8

require 'fileutils'
require 'logger'
require 'rack/patches'
require 'rack/degrade_mime_type'
require 'rack/relative_redirect'
require 'rack/remove_cache_buster'
require 'wiki/application'

config_file = if ENV['WIKI_CONFIG']
  ENV['WIKI_CONFIG']
else
  ::File.join(path, 'config.yml')
end

default_config = {
  :title        => 'Git-Wiki',
  :root         => path,
  :production   => false,
  :locale	=> 'en_US',
  :main_page    => 'Home',
  :sidebar_page => 'Sidebar',
  :external_img => false,
  :auth => {
    :service => 'yamlfile',
    :store   => ::File.join(path, '.wiki', 'users.yml'),
  },
  :cache => ::File.join(path, '.wiki', 'cache'),
  :mime => {
    :default => 'text/x-creole',
    :magic   => true,
  },
  :disabled_plugins => [
    'authorization/private_wiki',
    'tagging',
    'editor/antispam',
    'filter/benchmark',
  ],
  :rack => {
    :esi          => true,
    :embed        => false,
    :rewrite_base => nil,
    :deflater     => true,
  },
  :git => {
    :repository => ::File.join(path, '.wiki', 'repository'),
  },
  :log => {
    :level => 'INFO',
    :file  => ::File.join(path, '.wiki', 'log'),
  },
}

Wiki::Config.update(default_config)
Wiki::Config.load(config_file)

FileUtils.mkpath Wiki::Config.cache, :mode => 0755
FileUtils.mkpath ::File.dirname(Wiki::Config.log.file), :mode => 0755

logger = ::Logger.new(Wiki::Config.log.file, 25, 1024000)
logger.level = ::Logger.const_get(Wiki::Config.log.level)

use_lint if !Wiki::Config.production?

use(Rack::Config) {|env| env['rack.logger'] = logger }
use Rack::DegradeMimeType
use Rack::RelativeRedirect

if !Wiki::Config.rack.rewrite_base.blank?
  require 'rack/rewrite'
  use Rack::Rewrite, :base => Wiki::Config.rack.rewrite_base
end

if Wiki::Config.rack.deflater?
  use Rack::Deflater
end

use Rack::Static, :urls => ['/static'], :root => path

use Rack::RemoveCacheBuster # remove jquery cache buster
use Rack::Session::Pool

if Wiki::Config.rack.embed?
  gem 'rack-embed', '>= 0'
  require 'rack/embed'
  use Rack::Embed, :threaded => true
end

if Wiki::Config.rack.esi?
  gem 'minad-rack-esi', '>= 0'
  require 'rack/esi'
  use Rack::ESI

  if Wiki::Config.production?
    # FIXME: Replace with official release
    gem 'minad-rack-cache', '>= 0.5.2'
    require 'rack/cache'
    require 'rack/purge'
    use Rack::Purge
    use Rack::Cache,
      :verbose     => false,
      :metastore   => "file:#{::File.join(Wiki::Config.cache, 'rack', 'meta')}",
      :entitystore => "file:#{::File.join(Wiki::Config.cache, 'rack', 'entity')}"
  end
end

class LoggerOutput
  def initialize(logger); @logger = logger; end
  def write(text); @logger << text; end
end

use Rack::MethodOverride
use Rack::CommonLogger, LoggerOutput.new(logger)
run Wiki::Application.new(nil, :logger => logger)

logger.info "Wiki started in #{timer.stop.elapsed_ms}ms (#{Wiki::Config.production? ? 'Production' : 'Development'} mode)"
