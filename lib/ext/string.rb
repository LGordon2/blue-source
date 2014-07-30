class String
  def capitalize
    split.map { |name| name.split('-').map { |name| name.split("'").map { |name| name[0].upcase + name[1..-1].downcase }.join("'") }.join('-') }.join(' ')
  end
end
