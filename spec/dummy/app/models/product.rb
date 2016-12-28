class Product < ApplicationRecord
  belongs_to :employee
  has_many :pictures, as: :imageable
end
