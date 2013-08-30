class RegistersUser
  def self.call(params = {})
    username = params.fetch(:username)
    user_creator = params.fetch(:user_creator) { User }
    notifies_user = params.fetch(:notifies_user) { NotifiesUser }
    user_creator.find_or_create_by(username: username).tap do |user|
      notifies_user.(user)
    end
  end

  private

  def self.do_more_things_with(user)
  end
end