class CreateSensors < ActiveRecord::Migration
  def self.up
    create_table :sensors do |t|
      t.string :name
      t.float :temp

      t.timestamps
    end
  end

  def self.down
    drop_table :sensors
  end
end
