class CreateTrainingDeals < ActiveRecord::Migration
  def change
    create_table :training_deals do |t|
      t.integer :deal_id
      t.string :deal_type
      t.string :deal_headline
      t.string :url
      t.boolean :trained

      t.timestamps
    end
  end
end
