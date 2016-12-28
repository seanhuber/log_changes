class CreateMyModels < ActiveRecord::Migration[5.0]
  def change
    create_table :my_models do |t|
      t.string :string_attr
      t.timestamps
    end
  end
end
