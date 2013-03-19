class Install < ActiveRecord::Migration
  def change
    create_table :fine_print_agreements do |t|
      t.string :name, :null => false
      t.integer :version, :null => false
      t.text :content, :null => false
      t.string :confirmation_text, :default => 'I have read and agree to the terms and conditions above', :null => false
      t.boolean :display_name, :default => true
      t.boolean :display_version, :default => false
      t.boolean :display_updated, :default => false
      t.boolean :display_confirmation, :default => true
      t.boolean :ready, :default => false

      t.timestamps
    end

    create_table :fine_print_user_agreements do |t|
      t.integer :agreement_id, :null => false
      t.references :user, :polymorphic => true, :null => false

      t.timestamps
    end

    add_index :fine_print_agreements, [:name, :version]
    add_index :fine_print_user_agreements, :agreement_id
    add_index :fine_print_user_agreements, [:user_id, :user_type, :agreement_id], :name => 'index_fine_print_u_a_on_u_id_and_u_type_and_a_id'
  end
end
