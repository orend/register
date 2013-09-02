require 'spec_unit_helper'
require "./app/services/registers_user"

describe RegistersUser do
  let(:user_creator) { double('user_creator') }
  let(:notifies_user) { double('notifies_user') }
  let(:user) { double('user') }
  subject(:registers_user) { RegistersUser }

  it 'registers a new user' do
  	expect(user_creator).to receive(:find_or_create_by)
  			.with(username: 'username').and_return(user)
  	expect(notifies_user).to receive(:call).with(user, 'list_name')
  	expect(user).to receive(:update_attributes).with(email_list_name: 'list_name')

    registers_user.(username: 'username', user_creator: user_creator,
    	notifies_user: notifies_user, email_list_name: 'list_name')
  end

end
