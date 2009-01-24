#--
# Copyright (C) 2008 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
ActionMailer::Base.class_eval do
  class << self

    def method_missing_with_mailq(method_symbol, *parameters)#:nodoc:
      if method_symbol.id2name.match(/^queue_([_a-z]\w*)/)
        QueuedMail.create!(
          :object => new($1, *parameters).mail,
          :mailer_class_name => name
        )          
      else
        method_missing_without_mailq(method_symbol, *parameters)                
      end
    end
    alias_method_chain :method_missing, :mailq

  end
end