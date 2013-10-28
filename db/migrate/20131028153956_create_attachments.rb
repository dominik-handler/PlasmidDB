class CreateAttachments < ActiveRecord::Migration
  def change
    create_table :attachments do |t|
      t.string :name
      t.integer :plasmid_id

      t.timestamps
    end

    add_attachment :attachments, :file
  end
end
