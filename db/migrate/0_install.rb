class Install < ActiveRecord::Migration
  def change
    create_table :fine_print_agreements do |t|
      t.string :name
      t.integer :version
      t.text :content

      t.timestamps
    end

    create_table :fine_print_user_agreements do |t|
      t.integer :agreement_id
      t.references :user, :polymorphic => true

      t.timestamps
    end

    add_index :fine_print_agreements, [:name, :version]
    add_index :fine_print_user_agreements, :agreement_id
    add_index :fine_print_user_agreements, [:user_id, :user_type, :agreement_id], :name => 'index_fine_print_u_a_on_u_id_and_u_type_and_a_id'
  end
end
