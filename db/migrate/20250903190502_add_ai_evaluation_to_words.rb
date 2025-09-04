class AddAiEvaluationToWords < ActiveRecord::Migration[8.0]
  def change
    add_column :words, :ai_score, :integer
  end
end
