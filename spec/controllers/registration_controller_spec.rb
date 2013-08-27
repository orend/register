require 'spec_helper'

describe RegistrationController, :type => :controller do
  it 'creates a new user if username does not exist' do
    post :create, {username: 'username'}
    expect(assigns(:user).username).to eq('username')
  end
end
