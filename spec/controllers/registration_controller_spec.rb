require 'spec_helper'

describe RegistrationController, :type => :controller do
  it 'craetes a new user' do
    post :create, {username: 'username'}
    expect(assigns(:user).username).to eq('username')
  end

end
