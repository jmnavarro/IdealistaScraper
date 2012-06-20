class AddCityToFlats < ActiveRecord::Migration
  def self.up
    add_column :flats, :city, :string
  end

  def self.down
    remove_column :flats, :city
  end
end
