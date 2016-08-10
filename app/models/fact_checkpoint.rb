class FactCheckpoint < ActiveRecord::Base
  belongs_to :fact
  belongs_to :author, class_name: 'User'

  validates_presence_of :fact, :simulation, :author

  def self.build_from_fact(fact, author)
    fact.checkpoints.new(
      author: author,
      simulation: fact.simulation,
      name: fact.name,
      variable_name: fact.variable_name,
      expression: fact.expression,
    )
  end
  def self.create_from_fact(fact, author)
    FactCheckpoint.build_from_fact(fact, author).save!
  end

end
