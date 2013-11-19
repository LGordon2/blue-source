# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

#Build org chart.

#Alissa
manager = User.create([{username: "alissa.taylor", first_name: "alissa", last_name: "taylor", role: "Manager"}])
employee = User.create([
  {username: "andrew.williams"},
  {username: "lewis.gordon"},
  {username: "leroy.davis"},
  {username: "jonathan.gordon"},
  {username: "maria.lao"},
  {username: "robert.meeks"}
  ])
employee.each do |e|
  first_name_,last_name_ = e.username.split(".")
  e.update(first_name: first_name_, last_name: last_name_, manager: manager.first, role: "Consultant")
end

#Adam
manager = User.create([{username: "adam.thomas", first_name: "adam", last_name: "thomas", role: "Manager"}])
employee = User.create([
  {username: "waightstill.avery"},
  {username: "timothy.macior"},
  {username: "brent.monger"},
  {username: "nikki.eubanks"},
  {username: "timothy.ruckriegel"},
  {username: "stephen.king"},
  {username: "ethan.bell"}
  ])
employee.each do |e|
  first_name_,last_name_ = e.username.split(".")
  e.update(first_name: first_name_, last_name: last_name_, manager: manager.first, role: "Consultant")
end

#Perry
manager = User.create([{username: "perry.thomas", first_name: "perry", last_name: "thomas", role: "Manager"}])
employee = User.create([
  {username: "alfredo.gonzalez"},
  {username: "damien.storm"},
  {username: "daniel.mattice"},
  {username: "john.denny"},
  {username: "kia.tinsley"},
  {username: "matt.mitchell"}
  ])
employee.each do |e|
  first_name_,last_name_ = e.username.split(".")
  e.update(first_name: first_name_, last_name: last_name_, manager: manager.first, role: "Consultant")
end