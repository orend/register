require 'spec_helper'
require 'json'

describe UsersController, :type => :controller do
  it 'adds user to list' do
    user = mock_model(User)
    AddsUserToList.should_receive(:call).with(username: 'username',
      mailing_list_name: 'blog_list').and_return(user)
    put :update, format: :json, id: 1, mailing_list_id: 1#username: 'username'
  end
end
