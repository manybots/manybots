class CreateManybotsWeatherLocations < ActiveRecord::Migration
  def change
    create_table :manybots_weather_locations do |t|
      t.references :user
      t.string :code
      t.string :name
      t.string :lat
      t.string :long

      t.timestamps
    end
    add_index :manybots_weather_locations, :user_id
  end
end
