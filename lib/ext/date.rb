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