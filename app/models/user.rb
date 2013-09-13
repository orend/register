class User < ActiveRecord::Base
  validates_uniqueness_of :username
  validates_size_of :username, maximum: 12
end
