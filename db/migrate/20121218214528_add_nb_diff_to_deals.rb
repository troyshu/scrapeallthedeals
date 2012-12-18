class AddNbDiffToDeals < ActiveRecord::Migration
  def change
  	add_column :deals, :nb_diff, :float
  end
end
