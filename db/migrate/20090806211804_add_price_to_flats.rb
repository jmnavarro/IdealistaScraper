class AddPriceToFlats < ActiveRecord::Migration
  def self.up
    add_column :flats, :price, :integer
  end

  def self.down
    remove_column :flats, :price
  end
end
