require 'spec_helper'

describe Retrospectiva::ExtensionManager::ExtensionInstaller do    
  SOURCE  = File.join(Spec::Runner.configuration.fixture_path, 'runtime', 'extensions.yml')
  FIXTURE = File.join(RAILS_ROOT, 'tmp', 'spec', 'extensions.yml')

  def installer
    Retrospectiva::ExtensionManager::ExtensionInstaller    
  end

  def installed_names
    installer.installed_extension_names
  end

  def mock_extension(name)
    mock('Extension', :name => name)
  end

  before :all do
    FileUtils.mkdir_p(File.dirname(FIXTURE))
  end  

  after :all do
    installer.reload
  end  

  before do
    FileUtils.cp SOURCE, FIXTURE
    installer.stub!(:config_file).and_return(FIXTURE)
    installer.stub!(:test_mode?).and_return(false)
    installer.stub!(:system).and_return(false)
    installer.reload
  end

  after do
    FileUtils.rm FIXTURE, :force => true
  end  

  it 'should keep a list of installed extensions' do
    installer.installed_extension_names.should == ['retro_wiki', 'agile_pm']
  end

  describe 'installing extensions' do
    
    it 'should work correctly' do
      installed_names.should have(2).items
      installer.install(mock_extension('retro_blog'))
      installed_names.should have(3).items
      installed_names.should include('retro_blog')
    end

    it 'should only install if extension really exists' do
      installed_names.should have(2).items
      installer.install(mock_extension('_not_there_'))
      installed_names.should have(2).items
    end

    it 'should only install if not already installed' do
      installer.should_not_receive(:write_extension_table)
      installer.install(mock_extension('retro_wiki'))
      installed_names.should include('retro_wiki')
    end

  end

  describe 'removing extensions' do
    
    it 'should work correctly' do
      installed_names.should have(2).items
      installer.uninstall(mock_extension('retro_wiki'))
      installed_names.should have(1).items
      installed_names.should_not include('retro_wiki')
    end

    it 'should only remove if extension is really installed' do
      installer.should_not_receive(:write_extension_table)
      installer.uninstall(mock_extension('retro_blog'))
    end

  end

  describe 'downloading extensions' do

    it 'should use git to clone extension' do
      target = ::Rails.root.join('extensions', 'openid_auth')
      installer.should_receive(:system).
        with("git clone --depth 1 git://github.com/dim/retrospectiva.openid_auth.git #{target}").
        and_return(false)
      installer.download('git://github.com/dim/retrospectiva.openid_auth.git')
    end
    
  end
  
end
