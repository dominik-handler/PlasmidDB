class Plasmid < ActiveRecord::Base
  attr_accessible :author_id, :info, :internal_id, :name, :plasmid_map, :attachments_attributes, :glycerol_stock
  attr_accessible :backbone, :gene_insert, :species, :promoter, :mutations_deletions, :tag_1, :location_of_tag_1, :tag_2, :location_of_tag_2, :bacterial_resistance, :bacterial_resistance_other, :selectable_marker, :selectable_marker_other, :special_growth_conditions, :reference, :source, :source_specify, :notes, :dna_concentration
  serialize :info, ActiveRecord::Coders::Hstore

  has_attached_file :plasmid_map, styles: {thumb: ["400x400#", :png]}, :default_url => 'http://placehold.it/390x390'

  belongs_to :author
  has_many :attachments, :dependent => :destroy

  accepts_nested_attributes_for :attachments, :reject_if => lambda { |t| t['file'].nil? }

  validates :name, :presence => true
  validates :internal_id, :uniqueness => true
  validates :author_id, :presence => true
  validates :gene_insert, :presence => true
  validates :bacterial_resistance, :presence => true

  searchable do
    text :name, :as => :name_txtwc
    text :internal_id, :as => :internal_id_txtwc
    text :backbone, :as => :backbone_txtwc
    text :gene_insert, :as => :gene_insert_txtwc
    text :promoter, :as => :promoter_txtwc
    text :mutations_deletions, :as => :mutations_deletions_txtwc
    text :tag_1, :as => :tag_1_txtwc
    text :tag_2, :as => :tag_2_txtwc
    text :reference, :as => :reference_txtwc
    text :notes, :as => :notes_txtwc
    text :author_name, :as => :author_name_txtwc
  end

  def author_name
    self.author.username
  end
end
