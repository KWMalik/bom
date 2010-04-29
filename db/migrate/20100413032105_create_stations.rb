class CreateStations < ActiveRecord::Migration
  def self.up
    create_table :stations do |t|
      t.string :name
      t.float :lat
      t.float :long
      t.float :height
      t.boolean :bom
      t.string :url

      t.timestamps
    end
  end

  def self.down
    drop_table :stations
  end
end
