module VacationHelper
  module Holidays
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
  end
  
  module PTO
    include VacationHelper
    
    #class
    def calculate_fiscal_year(date = Date.current)
      date >= Date.new(date.year, 05, 01) ? date.year+1 : date.year
    end
    
    #class
    def fiscal_new_year_date(date = Date.current)
      Date.new(calculate_fiscal_year(date),05,01)
    end
    
    #class
    def calc_business_days_for_range(start_date, end_date)
      total = 0
      (start_date..end_date).each do |date|
        total += 1 unless date.saturday? or date.sunday? or 
        date.thanksgiving? or date.labor_day? or date.memorial_day? or
        date.christmas? or date.christmas_eve? or date.independence_day? or
        date.black_friday?
      end
      return total
    end
  end
  
  def self.included(base)
    base.extend(PTO)
  end
end

class Date
  include VacationHelper::Holidays
end
