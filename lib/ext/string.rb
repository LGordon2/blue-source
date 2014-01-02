class String
  def capitalize
    self.split('-').map {|_name| _name.split("'").map {|word| word[0].upcase + word[1..-1].downcase}.join("'")}.join("-")
  end
end