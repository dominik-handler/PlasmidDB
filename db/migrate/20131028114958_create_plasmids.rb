class CreatePlasmids < ActiveRecord::Migration
  def change
    create_table :plasmids do |t|
      t.string :name
      t.string :internal_id
      t.integer :author_id
      t.hstore :info

      t.timestamps
    end
  end
end
