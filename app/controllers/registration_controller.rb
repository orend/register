class RegistrationController < ApplicationController
  def create
    @user = RegistersUser.new.register(params[:username], user_creator: User)
    render json: @user
  end
end
