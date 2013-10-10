require 'spec_helper'
require "./app/services/adds_user_to_list"
require_relative "../../factories/user_factory"

describe AddsUserToList do
  before(:each) { @user = FactoryGirl.create('user', username: 'username') }
  let(:notifies_user) { double('notifies_user') }
  subject(:adds_user_to_list) { AddsUserToList }

  it 'registers a new user (slow version)' do
    expect(notifies_user).to receive(:call)
    adds_user_to_list.(username: 'username', mailing_list_name: 'list_name', notifies_user: notifies_user)
  end

  after(:each) do
    @user.destroy
  end
end
