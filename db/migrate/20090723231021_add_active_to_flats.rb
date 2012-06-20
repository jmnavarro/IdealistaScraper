class AddActiveToFlats < ActiveRecord::Migration
  def self.up
    add_column :flats, :active, :boolean
  end

  def self.down
    remove_column :flats, :active
  end
end
