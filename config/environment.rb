# Be sure to restart your server when you modify this file
RETROSPECTIVA_VERSION = '2.0.0'

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Skip frameworks you're not going to use. To use Rails without a database
  # you must remove the Active Record framework.
  config.frameworks -= [ :active_resource ]
  
  # Only load the plugins named here, in the order given. By default, all plugins 
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :enkoder, :retro_i18n, :retro_search, :validates_as_email, :wiki_engine ]

  config.controller_paths += [
    "#{RAILS_ROOT}/lib/retrospectiva/extension_manager/controllers"
  ].flatten

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Make Time.zone default to the specified zone, and make Active Record store time values
  # in the database in UTC, and return them converted to the specified local zone.
  # Run "rake -D time" for a list of tasks for finding time zone names. Uncomment to use default local time.
  config.time_zone = 'UTC'

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with "rake db:sessions:create")
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  unless $gems_rake_task
    config.active_record.observers = 
      'user_observer', 'project_observer', 'group_observer', 
      'changeset_observer', 'ticket_observer', 'ticket_change_observer'
  end
  
  config.after_initialize do
    RetroEM.load!(config)
    RetroCM.reload!
    Retrospectiva::Previewable.load!
    
    session_key = RetroCM[:general][:basic].setting(:session_key)
    if session_key.default?
      RetroCM[:general][:basic][:session_key] = "#{session_key.value}_#{ActiveSupport::SecureRandom.hex(3)}"
      RetroCM.save!
    end

    ActionController::UrlWriter.reload!
    ActionController::Base.session_options.merge!(
      :key    => RetroCM[:general][:basic][:session_key],
      :secret => Retrospectiva::Session.read_or_generate_secret
    )

    ActionView::Base.sanitized_bad_tags.merge %w(meta iframe frame layer ilayer link object embed bgsound from input select textarea style)
    ActionView::Base.sanitized_allowed_tags.merge %w(table tr td th)
    ActionView::Base.sanitized_allowed_attributes.merge %w(colspan rowspan style)

    ActionController::Base.cache_store = :file_store, RAILS_ROOT + '/tmp/cache'
  end unless $gems_rake_task
end

# Once everything is loaded
unless $gems_rake_task || $rails_rake_task
  RetroAM.load!
end

