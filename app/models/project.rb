class Project < ActiveRecord::Base
  has_many :project_histories
  has_many :employees, through: :project_histories

  has_many :project_leads
  has_many :leads, through: :project_leads, source: :employee
  belongs_to :client_partner, class_name: 'Employee'

  validates :name, presence: true, uniqueness: true
  validate :end_date_cannot_be_before_start_date

  private

  def end_date_cannot_be_before_start_date
    unless end_date.blank? || start_date.blank? || end_date > start_date
      errors.add(:end_date, "can't be before start date.")
    end
  end
end
