class AddJustScrapedColumnToDeals < ActiveRecord::Migration
  def change
  	add_column :deals, :just_scraped, :boolean, :default => false
  end
end
