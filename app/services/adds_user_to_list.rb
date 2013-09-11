class AddsUserToList
  def self.call(params)
    creates_user = params.fetch(:creates_user) { User }
    notifies_user = params.fetch(:notifies_user) { NotifiesUser }
    username = params.fetch(:username)
    email_list_name = params.fetch(:email_list_name)

    creates_user.find_or_create_by(username: username).tap do |user|
      notifies_user.(user, email_list_name)
      user.update_attributes(email_list_name: email_list_name)
    end
  end
end