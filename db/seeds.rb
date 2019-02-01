# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


puts 'CREATING POLITICIANS'

puts "--------CEO---------"
Politician.create(name: 'trump', age: 67, house_years: 23)


puts "--------TIER 1 SUBORDINATES-----------"
Politician.create(name: 'Obama', age: 67, house_years: 43)
Politician.create(name: 'Hillary', age: 67, house_years: 27)

puts "--------TIER 2 SUBORDINATES-----------"
Politician.create(name: 'ze1', age: 40, house_years: 12)
Politician.create(name: 'ze2', age: 34, house_years: 11)
Politician.create(name: 'ze3', age: 23, house_years: 10)
Politician.create(name: 'ze4', age: 40, house_years: 9)
Politician.create(name: 'ze5', age: 34, house_years: 8)
Politician.create(name: 'ze6', age: 23, house_years: 7)

puts "--------TIER  3 SUBORDINATES-----------"

Politician.create(name: 'ze7', age: 40, house_years: 6)
Politician.create(name: 'ze8', age: 34, house_years: 5)
Politician.create(name: 'ze9', age: 23, house_years: 4)
Politician.create(name: 'ze10', age: 40, house_years: 3)
Politician.create(name: 'ze11', age: 34, house_years: 2)
Politician.create(name: 'ze12', age: 49, house_years: 1)

puts "CREATING RELATIONSHIPS"

puts "CREATING TIER 1 RELATIONSHIPS"
Politician.find(1).active_relationships.create(subordinate_id: Politician.find(2).id)
Politician.find(1).active_relationships.create(subordinate_id: Politician.find(3).id)

puts "CREATING TIER 2 RELATIONSHIPS"
Politician.find(2).active_relationships.create(subordinate_id: Politician.find(4).id)
Politician.find(2).active_relationships.create(subordinate_id: Politician.find(5).id)
Politician.find(2).active_relationships.create(subordinate_id: Politician.find(6).id)

Politician.find(3).active_relationships.create(subordinate_id: Politician.find(7).id)
Politician.find(3).active_relationships.create(subordinate_id: Politician.find(8).id)
Politician.find(3).active_relationships.create(subordinate_id: Politician.find(9).id)

puts "Creating TIER 3 RELATIONSHIPS"

Politician.find(4).active_relationships.create(subordinate_id: Politician.find(10).id)
Politician.find(5).active_relationships.create(subordinate_id: Politician.find(11).id)
Politician.find(6).active_relationships.create(subordinate_id: Politician.find(12).id)
Politician.find(7).active_relationships.create(subordinate_id: Politician.find(13).id)
Politician.find(8).active_relationships.create(subordinate_id: Politician.find(14).id)
Politician.find(9).active_relationships.create(subordinate_id: Politician.find(15).id)

