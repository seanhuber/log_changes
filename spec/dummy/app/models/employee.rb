class Employee < ApplicationRecord
  has_many :pictures, as: :imageable
  has_many :products

  def to_s
    "#{first_name} #{last_name}"
  end
end
