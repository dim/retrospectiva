ActiveSupport::Dependencies.hook!

module Retrospectiva
  class DefaultContent
    
    DEFAULT_PRIORITIES = [ 
      {:rank => 4, :name => 'Normal', :default_value => true },
      {:rank => 6, :name => 'Enhancement'},
      {:rank => 5, :name => 'Minor'},
      {:rank => 3, :name => 'Major'},
      {:rank => 2, :name => 'Critical'},
      {:rank => 1, :name => 'Blocker'}
    ]
    
    DEFAULT_STATUSES = [ 
      {:rank => 1, :name => 'Open', :state_id => 1, :statement_id => 2, :default_value => true },
      {:rank => 2, :name => 'Fixed', :state_id => 3, :statement_id => 1},
      {:rank => 3, :name => 'Duplicate', :state_id => 3, :statement_id => 3},
      {:rank => 4, :name => 'Invalid', :state_id => 3, :statement_id => 3},
      {:rank => 5, :name => 'WorksForMe', :state_id => 3, :statement_id => 3},
      {:rank => 6, :name => 'WontFix', :state_id => 3, :statement_id => 3}
    ]
        
    def self.create
      new.tap do |creator|
        creator.create_priorities if Priority.count.zero?
        creator.create_statuses if Status.count.zero?
        creator.create_group unless Group.exists?(:name => 'Default')
        creator.create_public unless User.exists?(:name => 'Public')
        creator.create_admin unless User.exists?(:admin => true, :active => true)
        creator.create_tasks if Retrospectiva::TaskManager::Task.count.zero?
      end
    end

    def create_priorities
      puts 'Creating some default priorities'
      DEFAULT_PRIORITIES.each do |priority|
        Priority.create(priority)
      end
    end
  
    def create_statuses
      puts 'Creating some default statuses'
      DEFAULT_STATUSES.each do |priority|
        Status.create(priority)
      end
    end

    def create_tasks
      puts 'Creating default tasks'
      Retrospectiva::TaskManager::Task.create :name => 'sync_repositories', :interval => 600
      Retrospectiva::TaskManager::Task.create :name => 'process_mails', :interval => 300
    end

    def create_group
      puts 'Creating default group'
      Group.create!(:name => 'Default')
    end

    def create_public
      puts 'Creating default public user'
      random_pass = ActiveSupport::SecureRandom.base64(30)
      User.new( :name => 'Anonymous', :plain_password => random_pass, :plain_password_confirmation => random_pass ) do |user|
        user.username = 'Public'        
      end.save!
    end

    def create_admin
      puts 'Creating default admin user'
      User.new( :name => 'Administrator', :plain_password => 'password', :plain_password_confirmation => 'password' ) do |user|
        user.username = 'admin'        
        user.email = 'please@set.this'
        user.admin = true
      end.save!
    end

    def puts(*args)
      super unless RAILS_ENV == 'test'
    end

  end    
end

Retrospectiva::DefaultContent.create