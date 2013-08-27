class RegistersUser
  def initialize(params = {})
    @username = params.fetch(:username)
    @user_creator = params.fetch(:user_creator) { User }
  end

  def call
    user_creator.find_or_create_by(username: username)
  end

  private

  attr_reader :user_creator, :username
end