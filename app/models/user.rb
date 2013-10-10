class User < ActiveRecord::Base
  validates_uniqueness_of :username
  validates_size_of :username, maximum: 12

  def add_to_mailing_list(list_name)
    update_attributes(mailing_list_name: list_name)
  end

  def self.find_by_username!(username)
    find_by!(username: username)
  end
end
