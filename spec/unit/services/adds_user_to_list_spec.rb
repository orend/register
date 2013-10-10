require 'spec_unit_helper'
require "./app/services/mailing_list"

describe MailingList do
  let(:finds_user) { double('finds_user') }
  let(:notifies_user) { double('notifies_user') }
  let(:user) { double('user') }
  subject(:mailing_list) { MailingList }

  it 'registers a new user (slow version)' do
    expect(finds_user).to receive(:find_by_username!).with('username').and_return(user)
    expect(notifies_user).to receive(:call).with(user, 'list_name')
    expect(user).to receive(:add_to_mailing_list).with('list_name')

    adds_user_to_list.(username: 'username', mailing_list_name: 'list_name', finds_user: finds_user, notifies_user: notifies_user)
  end
end
