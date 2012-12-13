class AddStaticLocationToDeals < ActiveRecord::Migration
  def change
  	add_column :deals, :static_location, :string
  end
end
