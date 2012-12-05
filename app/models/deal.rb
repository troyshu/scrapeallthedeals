class Deal < ActiveRecord::Base
  attr_accessible :expiration, :external_id, :headline, :location, :name, :picture, :price, :savings, :site, :type, :url
end
