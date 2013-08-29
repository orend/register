require 'spec_unit_helper'
require "./app/services/registers_user"

describe RegistersUser do
  let(:user_creator) { double('user_creator') }
  subject(:registers_user) { RegistersUser.new }

  it 'registers a new user' do
  	expect(user_creator).to receive(:find_or_create_by).with(username: 'username')
    registers_user.(username: 'username', user_creator: user_creator)
  end

end
