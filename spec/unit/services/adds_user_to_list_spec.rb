require 'spec_unit_helper'
require "./app/services/adds_user_to_list"

describe AddsUserToList do
  let(:creates_user) { double('creates_user') }
  let(:notifies_user) { double('notifies_user') }
  let(:user) { double('user') }
  subject(:adds_user_to_list) { AddsUserToList }

  it 'registers a new user' do
    expect(creates_user).to receive(:find_or_create_by).with(username: 'username').and_return(user)
    expect(notifies_user).to receive(:call).with(user, 'list_name')
    expect(user).to receive(:update_attributes).with(email_list_name: 'list_name')

    adds_user_to_list.(username: 'username', email_list_name: 'list_name', creates_user: creates_user, notifies_user: notifies_user)
  end
end
