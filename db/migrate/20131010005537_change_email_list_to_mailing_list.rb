class ChangeEmailListToMailingList < ActiveRecord::Migration
  def change
  	rename_column :users, :email_list_name, :mailing_list_name
  end
end
