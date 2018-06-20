class CreateDummyUsers < ActiveRecord::Migration[4.2]
  def change
    create_table :dummy_users do |t|
      t.boolean :is_admin, null: false, default: false

      t.timestamps
    end
  end
end
