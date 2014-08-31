class ProjectHistory < ActiveRecord::Base
  belongs_to :employee
  belongs_to :project
  belongs_to :lead, class_name: 'Employee'

  scope :employee_current_projects, ->(employee) { where(employee: employee).where('roll_on_date <= :date and (roll_off_date IS NULL or roll_off_date >= :date)', date: Date.current) }

  validates :project_id, :employee_id, presence: true
  validate :roll_off_date_cannot_be_before_roll_on_date
  validate :maximum_date
  validate :minimum_date

  private

  def roll_off_date_cannot_be_before_roll_on_date
    unless roll_on_date.blank? || roll_off_date.blank? || roll_off_date >= roll_on_date
      errors.add(:roll_off_date, "can't be before start date.")
    end
  end

  def minimum_date
    minimum_date = Date.new(2000)

    errors.add(:roll_on_date, "is before the minimum date of #{minimum_date}.") if roll_on_date.present? && roll_on_date < minimum_date
    errors.add(:roll_off_date, "is before the minimum date of #{minimum_date}.") if roll_off_date.present? && roll_off_date < minimum_date
  end

  def maximum_date
    maximum_date = Date.new(2100)

    errors.add(:roll_on_date, "is after the maximum date of #{maximum_date}.") if roll_on_date.present? && roll_on_date > maximum_date
    errors.add(:roll_off_date, "is after the maximum date of #{maximum_date}.") if roll_off_date.present? && roll_off_date > maximum_date
  end
end
