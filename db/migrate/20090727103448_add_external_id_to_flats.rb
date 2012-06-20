class AddExternalIdToFlats < ActiveRecord::Migration
  def self.up
    add_column :flats, :external_id, :string
    add_index :flats,  [:spider, :external_id], :unique => true, :name => "flats_spider_external_id_idx"
  end

  def self.down
    remove_column :flats, :external_id
    remove_index :flats, "flats_spider_external_id_idx"
  end
end
