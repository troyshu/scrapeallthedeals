class CreateLocationUrlMaps < ActiveRecord::Migration
  def change
    create_table :location_url_maps do |t|
      t.string :site
      t.string :suffix
      t.string :static_location

      t.timestamps
    end
  end
end
