class RegistersUser
  def call(params = {})
    username = params.fetch(:username)
    user_creator = params.fetch(:user_creator) { User }
    user = user_creator.find_or_create_by(username: username)
    mailer = params.fetch(:mailer) { UserMailer }
    mailer.welcome_email(user).deliver
  end
end