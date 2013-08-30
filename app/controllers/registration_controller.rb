class RegistrationController < ApplicationController
  def create
    @user = RegistersUser.(username: params[:username])
    render json: @user
  end
end
