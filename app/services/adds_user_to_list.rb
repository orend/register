class AddsUserToList
  def self.call(username:, mailing_list_name:, finds_user: User,
                notifies_user: NotifiesUser)
    user = finds_user.find_by_username!(username)
    MailingList.new(name: mailing_list_name, notifies_user: notifies_user).add(user)
  end
end