class AddKindToFlats < ActiveRecord::Migration
  def self.up
    add_column :flats, :kind, :string, :limit => 3
  end

  def self.down
    remove_column :flats, :kind
  end
end
