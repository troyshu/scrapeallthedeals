# == Schema Information
#
# Table name: word_counts
#
#  id         :integer          not null, primary key
#  word       :string(255)
#  category   :string(255)
#  count      :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class WordCount < ActiveRecord::Base
  attr_accessible :category, :count, :word
end
