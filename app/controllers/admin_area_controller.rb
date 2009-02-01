#--
# Copyright (C) 2008 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class AdminAreaController < ApplicationController
  before_filter :authorize

  protected
  
    def project_not_found(id = nil)
      id ||= params[:id]
      raise ActiveRecord::RecordNotFound, "Unable to find project with ID=#{id}"
    end

end
