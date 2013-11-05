class FinePrintInstall < ActiveRecord::Migration
  def change
    create_table :fine_print_contracts do |t|
      t.string :name, :null => false
      t.integer :version
      t.string :title, :null => false
      t.text :content, :null => false
      t.boolean :is_latest, :null => false, :default => false

      t.timestamps
    end

    add_index :fine_print_contracts, :name
    add_index :fine_print_contracts, [:name, :is_latest]

    create_table :fine_print_signatures do |t|
      t.integer :contract_id, :null => false
      t.references :user, :polymorphic => true, :null => false

      t.timestamps
    end

    add_index :fine_print_signatures, :contract_id
    add_index :fine_print_signatures, [:user_id, :user_type, :contract_id], 
                                      :name => 'index_fine_print_s_on_u_id_and_u_type_and_c_id',
                                      :unique => true
  end
end
