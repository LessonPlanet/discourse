class AddSubHeaderToTopics < ActiveRecord::Migration
  def change
    add_column :topics, :sub_header, :string
  end
end
