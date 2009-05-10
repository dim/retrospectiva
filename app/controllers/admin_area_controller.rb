#--
# Copyright (C) 2009 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class AdminAreaController < ApplicationController
  before_filter :authorize
end
