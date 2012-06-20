class AddAreaToFlats < ActiveRecord::Migration
  def self.up
    add_column :flats, :area, :integer
  end

  def self.down
    remove_column :flats, :area
  end
end
