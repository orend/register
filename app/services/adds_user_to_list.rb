class AddsUserToList
  def self.call(username:, mailing_list_name:, finds_user: User,
                notifies_user: NotifiesUser)
    user = finds_user.find_by_username!(username)
    notifies_user.(user, mailing_list_name)
    user.add_to_mailing_list(mailing_list_name)
    user
  end
end