require 'spec_helper'
require 'json'

describe EmailListsController, :type => :controller do
  it 'creates a new user if username does not exist' do
    post :create, {username: 'username'}
    res = JSON.parse(@response.body)
    expect(res['username']).to eq('username')
  end
end
