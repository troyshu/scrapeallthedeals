class CreateDeals < ActiveRecord::Migration
  def change
    create_table :deals do |t|
      t.integer :external_id
      t.string :site
      t.string :name
      t.string :headline
      t.string :picture
      t.date :expiration
      t.string :url
      t.string :type
      t.float :price
      t.float :savings
      t.string :location

      t.timestamps
    end
  end
end
