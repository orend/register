class RegistersUser
  def register(username)
    User.find_or_create_by(username: username)
  end
end