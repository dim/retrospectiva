class Repository::Git::DiffScanner < Repository::Abstract::DiffScanner

  def source_revision_pattern
    /^\#\-{3} (\w{40})$/
  end

  def target_revision_pattern
    /^\#\+{3} (\w{40})$/
  end

end