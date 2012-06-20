class AddSpiderToFlats < ActiveRecord::Migration
  def self.up
    add_column :flats, :spider, :string
  end

  def self.down
    remove_column :flats, :spider
  end
end
