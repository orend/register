class UsersController < ApplicationController
  respond_to :json
  def show
    user = User.find(params[:user])
    respond_with user
  end
end
