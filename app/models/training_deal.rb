# == Schema Information
#
# Table name: training_deals
#
#  id            :integer          not null, primary key
#  deal_id       :integer
#  deal_type     :string(255)
#  deal_headline :string(255)
#  url           :string(255)
#  trained       :boolean
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class TrainingDeal < ActiveRecord::Base
  attr_accessible :deal_headline, :deal_id, :deal_type, :trained, :url
end
