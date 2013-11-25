require 'net/ldap'
class Employee < ActiveRecord::Base
  has_many :subordinates, class_name: "Employee", foreign_key: "manager_id"
  belongs_to :manager, class_name: "Employee"
  belongs_to :lead, class_name: "Lead"
  belongs_to :project
  
  attr_accessor :display_name
  
  validates :username, presence: true, uniqueness: true
  validates :username, format: /\A\w+\.\w+\z/
  validates :first_name, format: {with: /\A[a-z]+\z/, message: "must be lowercase."}
  validates :last_name, format: {with: /\A[a-z]+\z/, message: "must be lowercase."}
  validates :extension, numericality: {greater_than_or_equal_to: 1000, less_than_or_equal_to: 9999, allow_blank: true}
  validates :role, presence: true, inclusion: {in: ["Consultant", "Manager", "Director", "AVP"]}
  validates_with StartDateValidator
   
  def self.authenticate(user_params)
    employee = Employee.find_by(username: user_params[:username])
    return employee unless employee.nil?
    employee = Employee.new
    employee.username = user_params[:username].downcase
    employee.first_name,employee.last_name = user_params[:username].downcase.split(".")
    return employee
  end
  
  def display_name
    self.first_name.capitalize + " " + self.last_name.capitalize
  end
  
  def all_subordinates
    return if self.subordinates.empty?
    all_subordinates = self.subordinates
    self.subordinates.each do |employee|
      all_subordinates += employee.all_subordinates unless employee.all_subordinates.nil?
    end
    return all_subordinates
  end
  
  def above? other_employee
    if other_employee.manager == self
      return true
    end
    
    self.above? other_employee.manager unless other_employee.manager.nil?
  end
end
