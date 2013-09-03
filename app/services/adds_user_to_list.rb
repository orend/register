class AddsUserToList
  def self.call(username, email_list_name, params = {})
    creates_user = params.fetch(:creates_user) { User }
    notifies_user = params.fetch(:notifies_user) { NotifiesUser }

    creates_user.find_or_create_by(username: username).tap do |user|
      notifies_user.(user, email_list_name)
      user.update_attributes(email_list_name: email_list_name)
    end
  end
end