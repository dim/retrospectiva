#--
# Copyright (C) 2008 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class Admin::ExtensionsController < AdminAreaController
  def index
    @available = RetroEM.available_extensions
  end
end
