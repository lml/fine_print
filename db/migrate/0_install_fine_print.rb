class InstallFinePrint < ActiveRecord::Migration
  def change
    create_table :fine_print_contracts do |t|
      t.string :name, :null => false
      t.integer :version
      t.string :title, :null => false
      t.text :content, :null => false

      t.timestamps
    end

    add_index :fine_print_contracts, [:name, :version], :unique => true

    create_table :fine_print_signatures do |t|
      t.belongs_to :contract, :null => false
      t.belongs_to :user, :polymorphic => true, :null => false

      t.timestamps
    end

    add_index :fine_print_signatures, [:user_id, :user_type, :contract_id],
              :name => 'index_fine_print_s_on_u_id_and_u_type_and_c_id',
              :unique => true
    add_index :fine_print_signatures, :contract_id
  end
end
