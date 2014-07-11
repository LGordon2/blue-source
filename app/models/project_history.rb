class ProjectHistory < ActiveRecord::Base
  belongs_to :employee
  belongs_to :project
  belongs_to :lead, class_name: "Employee"

  validates :project_id, :employee_id, presence: true
  validate :roll_off_date_cannot_be_before_roll_on_date
  validate :minimum_and_maximum_dates

  private

  def roll_off_date_cannot_be_before_roll_on_date
    unless roll_on_date.blank? or roll_off_date.blank? or roll_off_date >= roll_on_date
      errors.add(:roll_off_date, "can't be before start date.")
    end
  end
  
  def minimum_and_maximum_dates
    minimum_date = Date.new(2000)
    maximum_date = Date.new(2100)
    
    unless roll_on_date.blank?
      unless minimum_date < roll_on_date
        errors.add(:roll_on_date, "is before the minimum date of #{minimum_date}.")
      end
      unless maximum_date > roll_on_date
        errors.add(:roll_on_date, "is after the maximum date of #{maximum_date}.")
      end
    end
    
    unless roll_off_date.blank?
      unless minimum_date < roll_off_date
        errors.add(:roll_off_date, "is before the minimum date of #{minimum_date}.")
      end
      unless maximum_date > roll_off_date
        errors.add(:roll_off_date, "is after the maximum date of #{maximum_date}.")
      end
    end
  end
end
