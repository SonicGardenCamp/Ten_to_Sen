class AddScoreToWords < ActiveRecord::Migration[8.0]
  def change
    add_column :words, :score, :integer
  end
end
