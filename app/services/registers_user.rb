class RegistersUser
  def register(username, options)
    user_creator = options.fetch(:user_creator)
    user_creator.find_or_create_by(username: username)
  end
end