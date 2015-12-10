$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'pmml_consumer'

RSpec.configure do |config|
  config.order = "random"
end
