class AddProxySignedContracts < ActiveRecord::Migration
  def change
    add_column :fine_print_contracts, :is_signed_by_proxy,
               :boolean, null: false, default: false
  end
end
