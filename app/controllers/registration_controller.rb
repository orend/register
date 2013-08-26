class RegistrationController < ApplicationController
  def create
    @user = User.find_or_create_by(username: params[:username])
    render json: @user
  end
end
