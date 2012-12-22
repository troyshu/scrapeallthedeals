# == Schema Information
#
# Table name: location_url_maps
#
#  id              :integer          not null, primary key
#  site            :string(255)
#  suffix          :string(255)
#  static_location :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class LocationUrlMap < ActiveRecord::Base
  attr_accessible :site, :static_location, :suffix
end
