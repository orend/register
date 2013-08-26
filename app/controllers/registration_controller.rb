class RegistrationController < ApplicationController
  def create
    @user = RegistersUser.(params[:username])
    render json: @user
  end
end
