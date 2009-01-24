require 'test/unit'

begin
  require File.dirname(__FILE__) + '/../../../../config/boot'
  require 'active_record'
  require 'validates_as_email'
rescue LoadError
  require 'rubygems'
  require_gem 'activerecord'
  require File.dirname(__FILE__) + '/../lib/validates_as_email'
end

class TestRecord < ActiveRecord::Base
  def self.columns; []; end
  attr_accessor :email
  validates_as_email :email
end

class ValidatesAsEmailTest < Test::Unit::TestCase
  def test_illegal_rfc822_email_address
    addresses = [
      'Max@Job 3:14', 
      'Job@Book of Job',
      'J. P. \'s-Gravezande, a.k.a. The Hacker!@example.com',
      ]
    addresses.each do |address|
      assert !TestRecord.new(:email => address).valid?, "#{address} should be illegal."
    end
  end

  def test_legal_rfc822_email_address
    addresses = [
      'test@example',
      'test@example.com', 
      'test@example.co.uk',
      '"J. P. \'s-Gravezande, a.k.a. The Hacker!"@example.com',
      'me@[187.223.45.119]',
      'someone@123.com',
      ]
    addresses.each do |address|
      assert TestRecord.new(:email => address).valid?, "#{address} should be legal."
    end
  end
end
