class AddMetaFieldsToPlasmid < ActiveRecord::Migration
  def change
    add_column :plasmids, :backbone, :string
    add_column :plasmids, :gene_insert, :string
    add_column :plasmids, :species, :string
    add_column :plasmids, :promoter, :string
    add_column :plasmids, :mutations_deletions, :string
    add_column :plasmids, :tag_1, :string
    add_column :plasmids, :location_of_tag_1, :string
    add_column :plasmids, :tag_2, :string
    add_column :plasmids, :location_of_tag_2, :string
    add_column :plasmids, :bacterial_resistance, :string
    add_column :plasmids, :bacterial_resistance_other, :string
    add_column :plasmids, :selectable_marker, :string
    add_column :plasmids, :selectable_marker_other, :string
    add_column :plasmids, :special_growth_conditions, :string
    add_column :plasmids, :reference, :string
    add_column :plasmids, :source, :string
    add_column :plasmids, :source_specify, :string
    add_column :plasmids, :notes, :text
    add_column :plasmids, :dna_concentration, :string
  end
end
