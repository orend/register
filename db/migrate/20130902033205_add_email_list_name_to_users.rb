class AddEmailListNameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :email_list_name, :string
  end
end
