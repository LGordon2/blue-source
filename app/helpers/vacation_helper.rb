module VacationHelper
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

class Date
  include VacationHelper
end
