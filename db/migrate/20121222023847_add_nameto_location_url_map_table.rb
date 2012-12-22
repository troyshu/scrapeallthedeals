class AddNametoLocationUrlMapTable < ActiveRecord::Migration
  def up
  	add_column :location_url_maps, :location_string, :string
  end

  def down
  end
end
