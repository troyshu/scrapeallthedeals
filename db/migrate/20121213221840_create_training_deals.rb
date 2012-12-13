class CreateTrainingDeals < ActiveRecord::Migration
  def change
    create_table :training_deals do |t|

      t.timestamps
    end
  end
end
