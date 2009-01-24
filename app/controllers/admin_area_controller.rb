#--
# Copyright (C) 2008 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class AdminAreaController < ApplicationController
  before_filter :authorize

  class << self

    def verify_restful_actions!(options = {})
      skip = options[:except] || []      
      verify_action :create, :method => :post     unless skip.include?(:create)
      verify_action :update, :method => :put      unless skip.include?(:update)
      verify_action :destroy, :method => :delete  unless skip.include?(:destroy)
    end
    protected :verify_restful_actions!

  end

  protected
  
    def project_not_found(id = nil)
      id ||= params[:id]
      raise ActiveRecord::RecordNotFound, "Unable to find project with ID=#{id}"
    end

end
