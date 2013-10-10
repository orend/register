require 'spec_helper'
require 'json'

describe MailingListsController, :type => :controller do
  it 'adds user to list' do
    user = mock_model(User)
    MailingList.should_receive(:new).and_return(user)
    post :add_user, format: :json, username: 'username'
  end
end
