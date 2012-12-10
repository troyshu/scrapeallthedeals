# == Schema Information
#
# Table name: deals
#
#  id          :integer          not null, primary key
#  external_id :integer
#  site        :string(255)
#  name        :string(255)
#  headline    :string(255)
#  picture     :string(255)
#  expiration  :date
#  url         :string(255)
#  type        :string(255)
#  price       :float
#  savings     :float
#  location    :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'test_helper'

class DealTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
