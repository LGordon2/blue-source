module VacationHelper
  #Calculates the fiscal year of the given date.
  def calculate_fiscal_year(date = Date.current)
    date >= Date.new(date.year, 05, 01) ? date.year+1 : date.year
  end
  
  #Calculates the next fiscal new year date for the given date.
  def fiscal_new_year_date(date = Date.current)
    Date.new(calculate_fiscal_year(date),05,01)
  end

  #Calculates the number of business days used for a date range.
  def calc_business_days_for_range(start_date, end_date)
    total = 0
    return total if start_date.blank? or end_date.blank?
    (start_date..end_date).each do |date|
      total += 1 unless date.saturday? or date.sunday? or date.is_orasi_holiday?
    end
    return total
  end
  def self.included(base)
    base.extend(VacationHelper)
  end
end
