class Plasmid < ActiveRecord::Base
  attr_accessible :author_id, :info, :internal_id, :name
  serialize :info, ActiveRecord::Coders::Hstore
end
