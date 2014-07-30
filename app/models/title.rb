class Title < ActiveRecord::Base
  has_many :employees, dependent: :nullify
  validates :name, uniqueness: { case_sensitive: false }, presence: true
end
