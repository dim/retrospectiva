# coding:utf-8
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SearchHelper do
  
  describe 'highlighting matched content parts' do

    before do
      @content = %Q(
        Create a database and a database user for Retrospectiva. Login to the database console or interface and execute the following SQL code (please set your own password):
        CREATE DATABASE IF NOT EXISTS retrospectiva;
        GRANT ALL PRIVILEGES ON retrospectiva.* 
          TO "retrospectiva"@"localhost" 
          IDENTIFIED BY "xxxxxxxxxxx";
        Go to the config/ directory of your Retrospectiva installation and rename the database.yml.todo file to database.yml
        cd config
        mv database.yml.todo database.yml
        Now open the database.yml with a text editor and set the database, username and password names according to your database settings in the production section. (If you get “No such file or directory – /var/run/mysqld/mysqld.sock” errors later, you can remove all the lines that start with “socket:”)      
      )      
    end
    
    it 'should correctly compile the regular expression' do
      @content.should_receive(:scan).with(/(?:editor)|(?:database\ console)/mi).and_return([])
      helper.highlight_matches(@content, 'editor "database console" -according')      
    end
    
    it 'should highlight all matching text parts' do
      helper.highlight_matches(@content, 'editor "database console" -according').should ==
      "\n        Create a database and a database user for Retrospectiva. Login to the <span class=\"highlight\">database console</span> or interface and execute the following SQL code (please set your own password):\n        CREATE DATABASE IF NOT EXISTS r ...<br/>" +
      "... database.yml\n        cd config\n        mv database.yml.todo database.yml" +
      "\n        Now open the database.yml with a text <span class=\"highlight\">editor</span> and set the database, username and password names according to your database settings in the production section. (If yo ...<br/>"
      
    end

    
  end
  

end
