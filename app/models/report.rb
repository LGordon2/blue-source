class Report < ActiveRecord::Base
  serialize :query_data
  validates :name, presence: true
end
