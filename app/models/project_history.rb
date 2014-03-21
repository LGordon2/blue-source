class ProjectHistory < ActiveRecord::Base
  belongs_to :employee
  belongs_to :project
  belongs_to :lead, class_name: "Employee"

  validates :project_id, presence: true
  validate :roll_off_date_cannot_be_before_roll_on_date

  private

  def roll_off_date_cannot_be_before_roll_on_date
    unless roll_on_date.blank? or roll_off_date.blank? or roll_off_date >= roll_on_date
      errors.add(:roll_off_date, "can't be before start date.")
    end
  end
end
