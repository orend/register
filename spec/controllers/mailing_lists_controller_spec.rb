require 'spec_helper'
require 'json'

describe MailingListsController, :type => :controller do
  it 'adds user to list' do
    user = mock_model(User)
    AddsUserToList.should_receive(:call).with(username: 'username',
      mailing_list_name: 'blog_list').and_return(user)
    post :add_user, format: :json, username: 'username'
  end
end
