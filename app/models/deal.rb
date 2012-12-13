# == Schema Information
#
# Table name: deals
#
#  id              :integer          not null, primary key
#  external_id     :integer
#  site            :string(255)
#  name            :string(255)
#  headline        :string(255)
#  picture         :string(255)
#  expiration      :date
#  url             :string(255)
#  deal_type       :string(255)
#  price           :float
#  savings         :float
#  location        :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  static_location :string(255)
#

class Deal < ActiveRecord::Base
  attr_accessible :expiration, :external_id, :headline, :location, :name, :picture, :price, :savings, :site, :type, :url
end
