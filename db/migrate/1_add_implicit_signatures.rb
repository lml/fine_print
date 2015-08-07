class AddImplicitSignatures < ActiveRecord::Migration
  def change
    add_column :fine_print_signatures, :is_implicit,
               :boolean, null: false, default: false
  end
end
