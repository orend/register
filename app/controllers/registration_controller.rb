class RegistrationController < ApplicationController
  def create
    @user = RegistersUser.new.(username: params[:username])
    render json: @user
  end
end
