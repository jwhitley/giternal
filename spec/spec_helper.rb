require 'simplecov'

begin
  require 'rspec'
rescue LoadError
  require 'rubygems'
  require 'rspec'
end

require 'giternal'
require 'giternal_helper'

Giternal.silence_logging

RSpec.configure do |config|
  config.before { GiternalHelper.clean! }
  config.after { GiternalHelper.clean! }
end
