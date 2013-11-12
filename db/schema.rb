# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20131112113954) do

  create_table "attachments", :force => true do |t|
    t.string   "name"
    t.integer  "plasmid_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
  end

  create_table "authors", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0,  :null => false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "username"
  end

  add_index "authors", ["email"], :name => "index_authors_on_email", :unique => true
  add_index "authors", ["reset_password_token"], :name => "index_authors_on_reset_password_token", :unique => true

  create_table "plasmids", :force => true do |t|
    t.string   "name"
    t.string   "internal_id"
    t.integer  "author_id"
    t.hstore   "info"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.string   "plasmid_map_file_name"
    t.string   "plasmid_map_content_type"
    t.integer  "plasmid_map_file_size"
    t.datetime "plasmid_map_updated_at"
    t.string   "backbone"
    t.string   "gene_insert"
    t.string   "species"
    t.string   "promoter"
    t.string   "mutations_deletions"
    t.string   "tag_1"
    t.string   "location_of_tag_1"
    t.string   "tag_2"
    t.string   "location_of_tag_2"
    t.string   "bacterial_resistance"
    t.string   "bacterial_resistance_other"
    t.string   "selectable_marker"
    t.string   "selectable_marker_other"
    t.string   "special_growth_conditions"
    t.string   "reference"
    t.string   "source"
    t.string   "source_specify"
    t.text     "notes"
    t.string   "dna_concentration"
    t.string   "glycerol_stock",             :default => ""
  end

  add_index "plasmids", ["info"], :name => "index_plasmids_on_info"

end
