# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


#Question.delete_all
#Choice.delete_all
#Inclusion.delete_all # add these back in if need to clear first (avoid duplicates)
#Answer.delete_all

ActiveRecord::Base.connection.execute('ANALYZE questions')
ActiveRecord::Base.connection.execute('ANALYZE answers')
ActiveRecord::Base.connection.execute('ANALYZE profiles')