class AddRegionCodeToFlats < ActiveRecord::Migration
  def self.up
    add_column :flats, :region_code, :string, :limit => 4
    add_index :flats, :region_code, :unique => false, :name => "flats_region_code_idx"
  end

  def self.down
    remove_index :flats, "flats_region_code_idx"
    remove_column :flats, :region_code
  end
end
