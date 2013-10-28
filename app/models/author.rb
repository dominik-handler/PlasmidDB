class Author < ActiveRecord::Base
  devise :database_authenticatable, :trackable

  attr_accessible :email, :password, :password_confirmation, :remember_me, :username

  has_many :plasmids
end
