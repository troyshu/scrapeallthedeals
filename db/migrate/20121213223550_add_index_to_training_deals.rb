class AddIndexToTrainingDeals < ActiveRecord::Migration
  def change
  	add_index :training_deals, [:deal_id]
  end
end
