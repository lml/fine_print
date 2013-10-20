class Install < ActiveRecord::Migration
  def change
    create_table :fine_print_agreements do |t|
      t.string :name, :null => false
      t.integer :version
      t.string :title, :null => false
      t.text :content, :null => false
      t.boolean :is_latest, :null => false, :default => false

      t.timestamps
    end

    add_index :fine_print_agreements, :name
    add_index :fine_print_agreements, [:name, :is_latest]

    create_table :fine_print_user_agreements do |t|
      t.integer :agreement_id, :null => false
      t.references :user, :polymorphic => true, :null => false

      t.timestamps
    end

    add_index :fine_print_user_agreements, :agreement_id
    add_index :fine_print_user_agreements, [:user_id, :user_type, :agreement_id], 
                                           :name => 'index_fine_print_u_a_on_u_id_and_u_type_and_a_id',
                                           :unique => true
  end
end
