class RegistrationController < ApplicationController
  def create
    @user = RegistersUser.new.register(params[:username])
    render json: @user
  end
end
