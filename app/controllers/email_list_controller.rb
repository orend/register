class EmailListController < ApplicationController
  def create
    @user = AddsUserToList.(username: params[:username], email_list_name: 'blog_list')
    render json: @user
  end
end
