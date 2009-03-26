class CreateHarks < ActiveRecord::Migration
  def self.up
    create_table :harks do |t|
      t.string :tidings
      t.timestamps
    end
  end

  def self.down
    drop_table :harks
  end
end
