class RenameTypeColumn < ActiveRecord::Migration
  def up
  	rename_column :deals, :type, :deal_type
  end

  def down
  end
end
