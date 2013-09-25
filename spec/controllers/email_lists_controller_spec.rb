require 'spec_helper'
require 'json'

describe EmailListsController, :type => :controller do
  it 'creates a new user if username does not exist' do
    user = mock_model(User)
    AddsUserToList.should_receive(:call).with(username: 'username',
      email_list_name: 'blog_list').and_return(user)
    post :add_user, format: :json, username: 'username'
  end
end
