class AddIndexToDeals < ActiveRecord::Migration
  def change
  	add_index :deals, [:external_id]
  end
end
