class RegistersUser
  def register(params)
    username = params.fetch(:username)
    User.find_or_create_by(username: username)
  end
end