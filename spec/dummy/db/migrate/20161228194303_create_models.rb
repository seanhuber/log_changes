class CreateModels < ActiveRecord::Migration[5.0]
  def change
    create_table :pictures do |t|
      t.string :name
      t.references :imageable, polymorphic: true, index: true
      t.timestamps
    end

    create_table :employees do |t|
      t.string :first_name
      t.string :last_name
      t.timestamps
    end

    create_table :products do |t|
      t.belongs_to :employee, index: true
      t.string :name
      t.timestamps
    end
  end
end
