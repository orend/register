require 'spec_helper'
require "./app/services/mailing_list"
require_relative "../../factories/user_factory"

describe MailingList do
  before(:each) { @user = FactoryGirl.create('user', username: 'username') }
  let(:notifies_user) { double('notifies_user') }
  subject(:mailing_list) { MailingList.new(username: 'username', name: 'list_name',
                                           notifies_user: notifies_user) }

  it 'registers a new user (slow version)' do
    expect(notifies_user).to receive(:call)
    mailing_list.(username: 'username')
  end

  after(:each) do
    @user.destroy
  end
end
