class Plasmid < ActiveRecord::Base
  attr_accessible :author_id, :info, :internal_id, :name, :plasmid_map, :attachments_attributes
  serialize :info, ActiveRecord::Coders::Hstore

  has_attached_file :plasmid_map, styles: {thumb: ["400x400#", :png]}, :default_url => 'http://placehold.it/390x390'

  belongs_to :author
  has_many :attachments, :dependent => :destroy

  accepts_nested_attributes_for :attachments, :reject_if => lambda { |t| t['file'].nil? }
end
