class Plasmid < ActiveRecord::Base
  attr_accessible :author_id, :info, :internal_id, :name
  serialize :info, ActiveRecord::Coders::Hstore
  has_attached_file :plasmid_map

  has_many :attachments
  belongs_to :author
end
