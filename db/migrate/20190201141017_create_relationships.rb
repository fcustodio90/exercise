class CreateRelationships < ActiveRecord::Migration[5.2]
  def change
    create_table :relationships do |t|
      t.integer :superior_id
      t.integer :subordinate_id

      t.timestamps
    end
  end
end
