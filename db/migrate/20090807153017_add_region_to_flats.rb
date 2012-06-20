class AddRegionToFlats < ActiveRecord::Migration
  def self.up
    add_column :flats, :region, :string
  end

  def self.down
    remove_column :flats, :region
  end
end
