class UsersController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  respond_to :json
  def update
    user = AddsUserToList.(username: params[:username], mailing_list_name: 'blog_list')
    respond_with user
  end
end
