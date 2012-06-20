class AddRoomsToFlats < ActiveRecord::Migration
  def self.up
    add_column :flats, :rooms, :integer
  end

  def self.down
    remove_column :flats, :rooms
  end
end
