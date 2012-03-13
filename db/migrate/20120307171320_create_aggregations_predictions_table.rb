class CreateAggregationsPredictionsTable < ActiveRecord::Migration
  def up
    create_table :aggregations_predictions, :id => false, :force => true do |t|
      t.integer :aggregation_id
      t.integer :prediction_id
    end
  end

  def down
    drop_table :aggregations_predictions
  end
end
