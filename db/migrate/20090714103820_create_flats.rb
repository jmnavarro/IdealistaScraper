class CreateFlats < ActiveRecord::Migration
  def self.up
    create_table :flats do |t|
      t.text :url
      t.string :address
      t.column "latitude", :decimal, :precision => 15, :scale => 10
      t.column "longitude", :decimal, :precision => 15, :scale => 10      
      
      t.timestamps
    end
  end

  def self.down
    drop_table :flats
  end
end
