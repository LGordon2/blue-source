module EmployeeHelper
  def time_ago_exact(on_date)
    time_array = []
    seconds = Date.current.to_time - on_date.to_time
    years = (seconds / (60*60*24*365)).floor
    time_array << pluralize(years,'year') unless years == 0
    seconds_left = seconds % (60*60*24*365)
    months = (seconds_left / (60*60*24*31)).floor
    time_array << pluralize(months,'months') unless months == 0
    seconds_left = seconds_left % (60*60*24*31)
    weeks = (seconds_left / (60*60*24*7)).floor
    time_array << pluralize(weeks,'week') unless weeks == 0
    seconds_left = seconds_left % (60*60*24*7)
    days = (seconds_left / (60*60*24)).floor
    time_array << pluralize(days,'day') unless days == 0 and (years > 0 or weeks > 0 or months > 0 or days > 0)
    return time_array.join(", ")
  end
end
