class RegistersUser
  def call(params = {})
    username = params.fetch(:username)
    user_creator = params.fetch(:user_creator) { User }
    user_creator.find_or_create_by(username: username).tap do |user|
      do_more_things_with(user)
    end
  end

  private

  def do_more_things_with(user)
  end
end