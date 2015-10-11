class User < ActiveRecord::Base
  has_many :spaces
end
