class RegistrationController < ApplicationController
  def create
    @user = RegistersUser.new.register(username: params[:username])
    render json: @user
  end
end
