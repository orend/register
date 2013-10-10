describe MailingList do
  let(:notifies_user) { double('notifies_user') }
  let(:user) { double('user') }

  it 'registers a new user' do
    expect(notifies_user).to receive(:call).with(user, 'list_name')
    expect(user).to receive(:add_to_mailing_list).with('list_name')

    mailing_list = MailingList.new(name: 'list_name', notifies_user: notifies_user)
    mailing_list.add(user)
  end
end