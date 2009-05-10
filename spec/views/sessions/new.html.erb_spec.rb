require File.dirname(__FILE__) + '/../../spec_helper'

describe "/sessions/new.html.erb" do
  before do
    template.stub!(:self_registration?).and_return(false)
    template.stub!(:account_management?).and_return(false)    
  end

  it 'should show the login form' do
    render '/sessions/new'
    template.should have_form_posting_to(session_path) do
      with_label_for 'user_username'
      with_text_field_for 'user_username'
      with_label_for 'user_password'
      with_text_field_for 'user_password'
    end
  end

  it 'should show link to home' do
    render '/sessions/new'
    template.should have_tag('a[href=?]', root_path)
  end

  it 'should show one single link below the form' do
    render '/sessions/new'
    template.should have_tag('.content-footer a', 1)
  end

  describe 'if self-registration is enabled' do    
    before { template.stub!(:self_registration?).and_return(true) }

    xit 'should show a link to registration' do
      render '/sessions/new'
      template.should have_tag('a[href=?]', registration_path)      
    end
  end

  describe 'if account-management is enabled' do    
    before { template.stub!(:account_management?).and_return(true) }

    xit 'should show a link to password recovery' do
      render '/sessions/new'
      template.should have_tag('a[href=?]', reset_password_path)      
    end    
  end
  
end