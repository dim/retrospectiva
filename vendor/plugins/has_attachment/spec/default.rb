share_as :DefautAttachmentSpec do
  
  def new_attachment(content, name = 'file.rb', type = 'text/plain')    
    @stream = ActionController::UploadedStringIO.new(content)
    @stream.original_path = name
    @stream.content_type = type
    Attachment.new(@stream)
  end

  def attachments(name)
    @loaded_fixtures['attachments'][name.to_s].find        
  end

  def connect_to_test_db!
    ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => DATABASE_PATH)
    ActiveRecord::Base.connection.create_table "attachments", :force => true do |t|
      t.string   "file_name"
      t.string   "content_type"
      t.string   "attachable_type", :limit => 30
      t.integer  "attachable_id"
      t.datetime "created_at"
      t.string   "type",            :limit => 20
    end  
  end
  
  def load_test_fixtures!
    File.open(TEMP_PATH + '/1', 'w') {|f| f << "#!/usr/bin/env ruby\nputs 'This is a ruby script!'" }
    File.open(TEMP_PATH + '/2', 'w') {|f| f << "GIF89a^A^@^A^@�^@^@���^@^@^@!�^D^A^@^@^@^@,^@^@^@^@^A^@^A^@^@^B^BD^A^@;if" }
    File.open(TEMP_PATH + '/3', 'w') {|f| f << "..." }

    fixtures = Fixtures.create_fixtures(FIXTURE_PATH, ['attachments'], { 'attachments' => 'Attachment' })
    { fixtures.name => fixtures }
  end

  before do
    Attachment.storage = { :type => :file_system, :path => TEMP_PATH }    
    connect_to_test_db!
    @loaded_fixtures = load_test_fixtures!
  end
  
  after do
    FileUtils.rm_rf(DATABASE_PATH)
  end
  
end
