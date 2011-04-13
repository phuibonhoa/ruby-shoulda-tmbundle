#!/usr/bin/env ruby
require "yaml"
require ENV['TM_SUPPORT_PATH'] + '/lib/ui'

module TextMate
  class ShareShould
    PREDEFINED_SHARE_SHOULDS_FILE = File.join(File.dirname(__FILE__), %w[.. shared_shoulds.yml])
    DEFAULT_SHARE_SHOULD_NAME = '[Default]'

    def use_should_snippet!
      share_should_name = nil
      if File.exists?(PREDEFINED_SHARE_SHOULDS_FILE)
        config = YAML.load_file(PREDEFINED_SHARE_SHOULDS_FILE)
        options = config['share_should']
        options.unshift(DEFAULT_SHARE_SHOULD_NAME)
        selected = options[TextMate::UI.menu(options)]
        share_should_name = selected unless selected == DEFAULT_SHARE_SHOULD_NAME
      end


      if share_should_name
        puts <<-EOT
use_should("#{share_should_name}")${2:.when("${1:condition}") do
  $0
end}
        EOT
      else
        puts <<-EOT
use_should("${1:shared_should name}")${3:.when("${2:condition}") do
  $0
end}
        EOT
      end      
    end
  end
end
