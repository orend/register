class MailingListsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  respond_to :json
  def add_user
    user = MailingList.new(mailing_list_name: 'blog_list').add(username: params[:username])
    respond_with user
  end
end
