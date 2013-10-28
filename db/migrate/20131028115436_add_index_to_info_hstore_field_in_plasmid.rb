class AddIndexToInfoHstoreFieldInPlasmid < ActiveRecord::Migration
  def change
    add_hstore_index :plasmids, :info
  end
end
