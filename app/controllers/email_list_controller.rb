class EmailListController < ApplicationController
  def create
    @user = AddsUserToList.(params[:username], 'blog_list')
    render json: @user
  end
end
