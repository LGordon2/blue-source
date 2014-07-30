class ::Date
  def thanksgiving?
    year = self.year
    first = Date.new(year, 11, 1)
    day_of_week = first.wday
    calc_day = 22 + (11 - day_of_week) % 7
    month == 11 and day == calc_day
  end

  def black_friday?
    year = self.year
    first = Date.new(year, 11, 1)
    day_of_week = first.wday
    calc_day = 22 + (11 - day_of_week) % 7 + 1
    month == 11 and day == calc_day
  end

  def christmas?
    month == 12 && day == 25
  end

  def christmas_eve?
    month == 12 && day == 24
  end

  def independence_day?
    month == 7 && day == 4
  end

  def labor_day?
    year = self.year
    first = Date.new(year, 9, 1)
    day_of_week = first.wday
    calc_day = 1 + (8 - day_of_week) % 7
    month == 9 and day == calc_day
  end

  def memorial_day?
    year = self.year
    first = Date.new(year, 5, 1)
    day_of_week = first.wday
    calc_day = 25 + (12 - day_of_week) % 7
    month == 5 and day == calc_day
  end

  def new_years_day?
    month == 1 && day == 1
  end

  def distance_in_months(from_date)
    month - from_date.month + (year - from_date.year) * 12
  end

  def distance_in_years(from_date)
    from_date = from_date.change(day: 28) if from_date.month == 2 and from_date.day == 29
    updated_for_year = from_date.change(year: year)
    year - from_date.year - (updated_for_year <= self ? 0 : 1)
  end

  def fiscal_new_year
    change(month: 5, day: 1, year: year + (month >= 5 ? 1 : 0))
  end

  def previous_fiscal_new_year
    change(month: 5, day: 1, year: year + (month >= 5 ? 0 : -1))
  end

  def current_fiscal_year
    month >= 5 ? year + 1 : year
  end

  def is_orasi_holiday?
    thanksgiving? || labor_day? || memorial_day? ||
        christmas? || christmas_eve? || independence_day? ||
        black_friday? || new_years_day?
  end
end
