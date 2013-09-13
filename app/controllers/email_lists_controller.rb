class EmailListsController < ApplicationController

  def create
    user = AddsUserToList.(username: params[:username], email_list_name: 'blog_list')
    render_response_to user
  end

  private

  def render_response_to(user)
    if user.errors.empty?
      render json: user
    else
      render json: user.errors, :status => :unprocessable_entity
    end
  end
end
