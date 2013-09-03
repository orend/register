require 'spec_helper'

describe EmailListController, :type => :controller do
  it 'creates a new user if username does not exist' do
    post :create, {username: 'username'}
    expect(assigns(:user).username).to eq('username')
  end
end
