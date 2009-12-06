$: << File.dirname(__FILE__) + '/../lib'

ENV["RAILS_ENV"] = "test"

require 'tempfile'
require 'rubygems'
require 'active_support'
require 'active_record'
require 'active_record/fixtures'
require 'action_controller'
require 'spec'

FIXTURE_PATH = File.dirname(__FILE__) + '/fixtures'
TEMP_PATH = File.dirname(__FILE__) + '/tmp'
DATABASE_PATH = TEMP_PATH + '/test.sqlite3'

require File.dirname(__FILE__) + '/default.rb'
require File.dirname(__FILE__) + '/../init.rb'