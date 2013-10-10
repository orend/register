class MailingList
  def initialize(name:, notifies_user: NotifiesUser)
    @name = name
    @notifies_user = notifies_user
  end

  def add(user)
    notifies_user.(user, name)
    user.add_to_mailing_list(name)
    user
  end

  private

  attr_reader :name, :notifies_user
end