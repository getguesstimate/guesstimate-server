# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

space = Space.create({name: 'Test', description: 'More test'})
space.graph = {
  metrics: [
       {id:"238jdj", spaceId: space.id, readableId:"PNYC",name:"People in NYC",location:{column:0,row:0}}
    ],
   guesstimates: [
       {metric:"238jdj",input:"5000/50"}
    ]
  }
space.save
