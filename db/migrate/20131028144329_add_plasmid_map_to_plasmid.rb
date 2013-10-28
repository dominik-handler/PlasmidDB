class AddPlasmidMapToPlasmid < ActiveRecord::Migration
  def change
    add_attachment :plasmids, :plasmid_map
  end
end
