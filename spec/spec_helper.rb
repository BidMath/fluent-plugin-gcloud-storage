$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'fluent/test'

if defined?(Test::Unit::AutoRunner)
  class Test::Unit::AutoRunner
    @@need_auto_run = false
  end
end
