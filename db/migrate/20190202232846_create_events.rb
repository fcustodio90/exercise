class CreateEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :events do |t|
      t.string :date
      t.boolean :locked, default: false
      t.references :politician, foreign_key: true

      t.timestamps
    end
  end
end
