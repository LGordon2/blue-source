module EmployeeHelper
  def time_ago_exact(on_date)
    time_array = []
    seconds = Date.current.to_time - on_date.to_time
    years = (seconds / (60*60*24*365)).floor
    time_array << pluralize(years,'year') unless years == 0
    seconds_left = seconds % (60*60*24*365)
    months = (seconds_left / (60*60*24*31)).floor
    time_array << pluralize(months,'month') unless months == 0
    seconds_left = seconds_left % (60*60*24*31)
    weeks = (seconds_left / (60*60*24*7)).floor
    time_array << pluralize(weeks,'week') unless weeks == 0
    seconds_left = seconds_left % (60*60*24*7)
    days = (seconds_left / (60*60*24)).floor
    time_array << pluralize(days,'day') unless days == 0 and (years > 0 or weeks > 0 or months > 0 or days > 0)
    return time_array.join(", ")
  end
  
  def accrual_rates(years_of_employment)
    months_in_year = 12.0
    case years_of_employment
    when 0..2 then 10.0/months_in_year
    when 3..5 then 15.0/months_in_year
    else 20.0/months_in_year
    end
  end
  
  def accrued_vacation_days_on_date(date,anniversary_date=nil)
    #Calculate total months from previous fiscal new year to date.
    months = date.distance_in_months(date.previous_fiscal_new_year) + 1
    years_with_orasi = 1
    
    #Calculate total months from anniversary to date.
    unless anniversary_date.nil?
      if anniversary_date > date.previous_fiscal_new_year
        months = date.distance_in_months(anniversary_date)
        months += 1 if anniversary_date.day == 1
      end
      #Calculate the years the employee has been with Orasi
      years_with_orasi = date.distance_in_years(anniversary_date)
      
      years_with_orasi = 1 if years_with_orasi <= 0
      
      #Calculate anniversary date for this year.
      anniversary_months = anniversary_date.day == 1 ? 1 : 0
      anniversary_date = anniversary_date.change(day:1,year: date.current_fiscal_year - (anniversary_date.month >= 5 ? 1 : 0))
      anniversary_date = anniversary_date + 1.month
      anniversary_months += date.distance_in_months(anniversary_date) + 1
      if anniversary_months > 0
        return ((accrual_rates(years_with_orasi-1)*(months - anniversary_months)) + (accrual_rates(years_with_orasi)*anniversary_months)).round(2)
      elsif anniversary_months == 0 
        years_with_orasi -= 1
      end
    end
    (accrual_rates(years_with_orasi)*(months)).round(2)
    
  end
end
