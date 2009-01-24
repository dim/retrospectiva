module AssociationProxies::ChangesetChanges

  def build_copied(*tokens)
    tokens.each do |destination, origin, from_revision|
      build :name => 'CP', 
        :path => sanitize_path(destination), 
        :from_path => sanitize_path(origin), 
        :from_revision => from_revision
    end
  end

  def build_moved(*tokens)
    tokens.each do |destination, origin, from_revision|
      build :name => 'MV',
        :path => sanitize_path(destination), 
        :from_path => sanitize_path(origin), 
        :from_revision => from_revision 
    end    
  end
  
  def build_added(*tokens)
    tokens.each do |path|        
      build :name => 'A', :path => path
    end  
  end

  def build_deleted(*tokens)
    tokens.each do |path|
      build :name => 'D', :path => path 
    end    
  end

  def build_modified(*tokens)
    tokens.each do |path|
      build :name => 'M', :path => path 
    end    
  end


  private

    def sanitize_path(path)
      path ? path.chomp('/') : nil
    end

end