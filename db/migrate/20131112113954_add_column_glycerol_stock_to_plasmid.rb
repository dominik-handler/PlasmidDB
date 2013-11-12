class AddColumnGlycerolStockToPlasmid < ActiveRecord::Migration
  def change
    add_column :plasmids, :glycerol_stock, :string, :default => ""
  end
end
