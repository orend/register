class RegistrationController < ApplicationController
  def create
    @user = RegistersUser.call(params[:username])
    render json: @user
  end
end
