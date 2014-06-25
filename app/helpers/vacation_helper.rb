module VacationHelper
  class ::Date
    def thanksgiving?
      year = self.year
      first = Date.new(year, 11, 1)
      day_of_week = first.wday
      calc_day = 22 + (11 - day_of_week) % 7
      self.month == 11 and self.day == calc_day
    end

    def black_friday?
      year = self.year
      first = Date.new(year, 11, 1)
      day_of_week = first.wday
      calc_day = 22 + (11 - day_of_week) % 7 + 1
      self.month == 11 and self.day == calc_day
    end

    def christmas?
      self.month == 12 and self.day == 25
    end

    def christmas_eve?
      self.month == 12 and self.day == 24
    end

    def independence_day?
      self.month == 7 and self.day == 4
    end

    def labor_day?
      year = self.year
      first = Date.new(year, 9, 1)
      day_of_week = first.wday
      calc_day = 1 + (8 - day_of_week) % 7
      self.month == 9 and self.day == calc_day
    end

    def memorial_day?
      year = self.year
      first = Date.new(year, 5, 1)
      day_of_week = first.wday
      calc_day = 25 + (12 - day_of_week) % 7
      self.month == 5 and self.day == calc_day
    end
    
    def new_years_day?
      self.month == 1 and self.day == 1
    end
    
    def distance_in_months(from_date)
      self.month - from_date.month + (self.year - from_date.year)*12
    end
    
    def distance_in_years(from_date)
      from_date = from_date.change(day: 28) if from_date.month == 2 and from_date.day == 29
      updated_for_year = from_date.change(year: self.year)
      self.year - from_date.year - (updated_for_year <= self ? 0 : 1)
    end
    
    def fiscal_new_year
      self.change(month: 5,day: 1,year: self.year + (self.month >= 5 ? 1 : 0)) 
    end
    
    def previous_fiscal_new_year
      self.change(month: 5,day: 1,year: self.year + (self.month >= 5 ? 0 : -1)) 
    end
    
    def current_fiscal_year
      self.month >= 5 ? self.year+1 : self.year
    end

    def is_orasi_holiday?
      thanksgiving? or labor_day? or memorial_day? or
          christmas? or christmas_eve? or independence_day? or
          black_friday? or new_years_day?
    end
  end
  
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
