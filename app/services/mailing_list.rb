class MailingList
  def add(username:, finds_user: User)
    user = finds_user.find_by_username!(username)
    notifies_user.(user, name)
    user.add_to_mailing_list(name)
    user
  end
  def self.initialize(name:, notifies_user: NotifiesUser)
    @name = name
    @notifies_user = notifies_user
  end

  private

  attr_reader :name, :notifies_user
end