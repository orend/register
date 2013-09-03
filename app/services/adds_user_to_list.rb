class AddsUserToList
  def self.call(username, email_list_name, params = {})
    user_creator = params.fetch(:user_creator) { User }
    notifies_user = params.fetch(:notifies_user) { NotifiesUser }

    user_creator.find_or_create_by(username: username).tap do |user|
      notifies_user.(user, email_list_name)
      user.update_attributes(email_list_name: email_list_name)
    end
  end
end