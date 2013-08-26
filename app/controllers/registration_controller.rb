class RegistrationController < ApplicationController
  def create
    @user = RegistersUser.call(params[:username], user_creator: User)
    render json: @user
  end
end
