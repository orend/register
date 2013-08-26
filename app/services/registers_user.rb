class RegistersUser
  def self.call(username, options = {})
    user_creator = options.fetch(:user_creator) { User }
    user_creator.find_or_create_by(username: username)
  end
end