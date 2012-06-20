class AddIndicesToFlats < ActiveRecord::Migration
  def self.up
    add_index :flats, :active, :unique => false, :name => "flats_active_idx"
    add_index :flats, :kind, :unique => false, :name => "flats_kind_idx"
    add_index :flats,  [:latitude, :longitude], :unique => false, :name => "flats_location_idx"
    add_index :flats,  :latitude, :unique => false, :name => "flats_lat_idx"
    add_index :flats,  :longitude, :unique => false, :name => "flats_lon_idx"
  end

  def self.down
    remove_index :flats, "flats_active_idx"
    remove_index :flats, "flats_kind_idx"
    remove_index :flats, "flats_location_idx"
    remove_index :flats, "flats_lat_idx"
    remove_index :flats, "flats_lon_idx"
  end
end
