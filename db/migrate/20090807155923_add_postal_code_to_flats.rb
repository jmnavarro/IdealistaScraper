class AddPostalCodeToFlats < ActiveRecord::Migration
  def self.up
    add_column :flats, :postal_code, :string, :limit => 16
  end

  def self.down
    remove_column :flats, :postal_code
  end
end
