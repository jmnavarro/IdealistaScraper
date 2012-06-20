class AddPlaceIndicesToFlats < ActiveRecord::Migration
  def self.up
    add_index :flats, :price, :unique => false, :name => "flats_price_idx"
    add_index :flats, :rooms, :unique => false, :name => "flats_rooms_idx"
    add_index :flats, :area, :unique => false, :name => "flats_area_idx"
    add_index :flats,  [:region, :city, :postal_code], :unique => false, :name => "flats_place_idx"
    add_index :flats,  [:region, :city], :unique => false, :name => "flats_place2_idx"
    add_index :flats,  [:region, :postal_code], :unique => false, :name => "flats_place3_idx"
    add_index :flats,  [:city, :postal_code], :unique => false, :name => "flats_place4_idx"
    add_index :flats,  :region, :unique => false, :name => "flats_region_idx"
    add_index :flats,  :city, :unique => false, :name => "flats_city_idx"
    add_index :flats,  :postal_code, :unique => false, :name => "flats_postal_code_idx"
  end

  def self.down
    remove_index :flats, "flats_active_idx"
    remove_index :flats, "flats_price_idx"
    remove_index :flats, "flats_rooms_idx"
    remove_index :flats, "flats_area_idx"
    remove_index :flats, "flats_place_idx"
    remove_index :flats, "flats_place2_idx"
    remove_index :flats, "flats_place3_idx"
    remove_index :flats, "flats_place4_idx"
    remove_index :flats, "flats_region_idx"
    remove_index :flats, "flats_city_idx"
    remove_index :flats, "flats_postal_code_idx"
  end
end
