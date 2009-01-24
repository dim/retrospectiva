#!/usr/bin/env ruby

unless Object.const_defined?(:RAILS_ROOT)
  require File.dirname(__FILE__) + '/../config/environment'
end

if Priority.count.zero?
  puts 'Creating some default priorities' unless RAILS_ENV == 'test'
  [ {:rank => 4, :name => 'Normal', :default_value => true },
    {:rank => 6, :name => 'Enhancement'},
    {:rank => 5, :name => 'Minor'},
    {:rank => 3, :name => 'Major'},
    {:rank => 2, :name => 'Critical'},
    {:rank => 1, :name => 'Blocker'}].each do |priority|
    Priority.create(priority) unless Priority.find_by_name(priority[:name])
  end
end

if Status.count.zero?
  puts 'Creating some default status' unless RAILS_ENV == 'test'
  [ {:rank => 1, :name => 'Open', :state_id => 1, :statement_id => 2, :default_value => true },
    {:rank => 2, :name => 'Fixed', :state_id => 3, :statement_id => 1},
    {:rank => 3, :name => 'Duplicate', :state_id => 3, :statement_id => 3},
    {:rank => 4, :name => 'Invalid', :state_id => 3, :statement_id => 3},
    {:rank => 5, :name => 'WorksForMe', :state_id => 3, :statement_id => 3},
    {:rank => 6, :name => 'WontFix', :state_id => 3, :statement_id => 3}].each do |status|
    Status.create(status) unless Status.find_by_name(status[:name])
  end
end

unless Group.find_by_name('Default')
  puts 'Creating default group' unless RAILS_ENV == 'test'
  Group.create!(:name => 'Default')
end

unless User.find_by_username('Public')
  puts 'Creating default public user' unless RAILS_ENV == 'test'
  random_pass = Randomizer.string
  user = User.new(
    :name => 'Anonymous', 
    :plain_password => random_pass,
    :plain_password_confirmation => random_pass
  ) 
  user.username = 'Public'
  user.save!
  user = nil
end

unless User.find_by_admin(true)
  puts 'Creating default admin' unless RAILS_ENV == 'test'
  user = User.find_by_username('admin')
  
  user = User.new( 
    :name => 'Administrator', 
    :plain_password => 'password',
    :plain_password_confirmation => 'password'
  ) unless user

  user.username = 'admin'
  user.email = 'please@set.this'
  user.admin = true
  user.save!
  user = nil
end
