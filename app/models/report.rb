class Report < ActiveRecord::Base
  serialize :query_data
  belongs_to :employee
  
  validates :name, presence: true


end
