# frozen_string_literal: true

Dir[File.join(__dir__, 'lib', '**', '*.rb')].sort.each { |file| require file }

CLI.new.run
