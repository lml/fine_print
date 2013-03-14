class InstallFinePrint < ActiveRecord::Migration
  def change
    create_table :fine_print_agreements do |t|
      t.string :name
      t.text :content
      t.integer :version

      t.timestamps
    end

    create_table :fine_print_user_agreements do |t|
      t.integer :user_id
      t.integer :agreement_id

      t.timestamps
    end

    add_index :fine_print_agreements, [:name, :version]
    add_index :fine_print_user_agreements, [:user_id, :agreement_id]
    add_index :fine_print_user_agreements, :agreement_id
  end
end
