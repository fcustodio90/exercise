class CreatePoliticians < ActiveRecord::Migration[5.2]
  def change
    create_table :politicians do |t|
      t.string :name
      t.integer :age
      t.integer :house_years
      t.boolean :locked, default: false

      t.timestamps
    end
  end
end
