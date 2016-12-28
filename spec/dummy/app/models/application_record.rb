class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  include LogChanges::Base
end
