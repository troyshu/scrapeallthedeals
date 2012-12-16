class CreateWordCounts < ActiveRecord::Migration
  def change
    create_table :word_counts do |t|
      t.string :word
      t.string :category
      t.integer :count

      t.timestamps
    end
  end
end
