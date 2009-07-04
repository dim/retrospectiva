module Spec::RepositoryInclude
  def mock_text_node(options = {})
    mock_node options.reverse_merge(:content_type => :text,
      :binary? => false,
      :path => 'folder/file.txt', 
      :name => 'file.txt', 
      :content => 'CONTENT')
  end

  def mock_binary_node
    mock_node :content_type => :binary, :name => 'file.ogg'
  end

  def mock_image_node
    mock_node :content_type => :image, :name => 'file.gif'
  end

  def mock_node(options = {})
    mock_model Repository::Abstract::Node, options.reverse_merge(
      :author => 'author',
      :date => 1.month.ago,
      :revision => 'R12',
      :short_revision => 'R12',
      :selected_revision => 'R15',
      :latest_revision? => true,
      :log => 'LOG1',
      :properties => {'P1' => 'A'},
      :dir? => false,
      :sub_nodes => [])
  end
end