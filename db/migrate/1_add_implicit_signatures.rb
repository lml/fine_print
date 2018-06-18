class AddImplicitSignatures < ActiveRecord::Migration[4.2]
  def change
    add_column :fine_print_signatures, :is_implicit,
               :boolean, null: false, default: false
  end
end
