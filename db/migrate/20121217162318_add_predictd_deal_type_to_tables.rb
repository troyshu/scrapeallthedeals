class AddPredictdDealTypeToTables < ActiveRecord::Migration
  def change
  	add_column :deals, :predicted_deal_type, :string
  	add_column :training_deals, :predicted_deal_type, :string
  end
end
