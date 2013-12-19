class StartDateValidator < ActiveModel::Validator
  def validate(record)
    unless record.start_date.blank? or record.start_date <= DateTime.current
      record.errors[:start_date] << 'must be before current date.'
    end
  end
end