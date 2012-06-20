class AddContactPhoneToFlats < ActiveRecord::Migration
  def self.up
    add_column :flats, :contact_phone, :string, :limit => 16
  end

  def self.down
    remove_column :flats, :contact_phone
  end
end
