namespace :retro do

  desc 'Process mail queue, deliver outgoing emails'
  task :process_mails => :environment do
    ActiveSupport::Dependencies.hook!
    QueuedMail.pending.each(&:deliver!)
  end

  desc 'Synchronize the changes in your repositories with Retrospectiva'
  task :sync_repositories => :environment do
    ActiveSupport::Dependencies.hook!
    Repository.find(:all).each do |repos|
      Repository.logger.info `#{repos.sync_callback}` unless repos.sync_callback.blank?
      repos.sync_changesets
    end
  end

end
