class CreateHarkers < ActiveRecord::Migration
  def self.up
    create_table :harkers do |t|
      t.string :name
      t.date :birthday
      t.timestamps
    end
  end

  def self.down
    drop_table :harkers
  end
end
