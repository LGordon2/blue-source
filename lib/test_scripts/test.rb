anniversary_date = Date.new(2010,12,10)
#Correct year to put in for fiscal year.
correct_year_for_fiscal_year = if anniversary_date >= Date.new(anniversary_date.year,1,1) and anniversary_date < Date.new(anniversary_date.year,5,1) then Vacation.calculate_fiscal_year else Vacation.calculate_fiscal_year-1 end
puts "Employee has been with Orasi for #{correct_year_for_fiscal_year - anniversary_date.year} years on #{Date.new(correct_year_for_fiscal_year,anniversary_date.month,anniversary_date.day)}"

#m is days from anniversary date (day of year hired) to fiscal new year year (May 1st)
m = (Vacation.fiscal_new_year_date - Date.new(correct_year_for_fiscal_year,anniversary_date.month,anniversary_date.day)).to_i
#p is days from fiscal new year year to anniversary date+
p = (Date.new(correct_year_for_fiscal_year+1,anniversary_date.month,anniversary_date.day) - Vacation.fiscal_new_year_date).to_i
#n is days of vacation given before upcoming anniversary. 0-3 years = 10 | 3-6 years = 15 | 6+ years = 20

years_with_orasi_on_anniversary = correct_year_for_fiscal_year - anniversary_date.year
if years_with_orasi_on_anniversary < 0
  raise Exception
end
n = case (years_with_orasi_on_anniversary)
when 0..3 then 10
when 4..6 then 15
else 20
end
#d is days of vacation given after upcoming anniversary. 0-3 years = 10 | 3-6 years = 15 | 6+ years = 20
d = case (years_with_orasi_on_anniversary)
when 0..2 then 10
when 3..5 then 15
else 20
end

va = if Date.current >= Date.new(correct_year_for_fiscal_year,anniversary_date.month,anniversary_date.day) then ((p/365.0)*n+(m/365.0)*d).round else n end
puts "p:#{p} n:#{n} m:#{m} d:#{d} Vacation days:#{va}"
