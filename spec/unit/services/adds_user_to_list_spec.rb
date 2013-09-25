require 'spec_unit_helper'
require "./app/services/adds_user_to_list"

describe AddsUserToList do
  let(:finds_user) { double('finds_user') }
  let(:notifies_user) { double('notifies_user') }
  let(:user) { double('user') }
  subject(:adds_user_to_list) { AddsUserToList }

  it 'registers a new user (slow version)' do
    expect(finds_user).to receive(:find_by).with(username: 'username').and_return(user)
    expect(notifies_user).to receive(:call).with(user, 'list_name')
    expect(user).to receive(:update_attributes).with(email_list_name: 'list_name')

    adds_user_to_list.(username: 'username', email_list_name: 'list_name', finds_user: finds_user, notifies_user: notifies_user)
  end
end
