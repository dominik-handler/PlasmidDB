class Attachment < ActiveRecord::Base
  attr_accessible :name, :plasmid_id, :file
  has_attached_file :file

  belongs_to :plasmid
end
