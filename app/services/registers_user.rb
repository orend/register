class RegistersUser
  def self.call(params = {})
    username = params.fetch(:username)
    user_creator = params.fetch(:user_creator) { User }
    notifies_user = params.fetch(:notifies_user) { NotifiesUser }
    email_list_name = params.fetch(:email_list_name) { 'landing_page' }
    user_creator.find_or_create_by(username: username).tap do |user|
      notifies_user.(user, email_list_name)
      user.update_attributes(email_list_name: email_list_name)
    end
  end
end