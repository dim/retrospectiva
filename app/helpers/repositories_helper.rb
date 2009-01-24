module RepositoriesHelper

  def format_log(log)
    method = wikify_log? ? :markup : :simple_markup
    send(method, log)
  end

  protected

    def wikify_log?
      RetroCM[:content][:format][:changeset_logs] == 'wikified'
    end

end
