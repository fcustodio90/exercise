class Politician < ApplicationRecord

has_many :active_relationships, class_name:  "Relationship",
                                foreign_key: "superior_id",
                                dependent:   :destroy

has_many :oldreplicas


  def add_subordinate(politician)
    if active_relationships.exists?(subordinate: politician)
      return true
    else
      active_relationships.create(subordinate: politician)
    end
  end

  def superior
    if !Relationship.find_by(subordinate: self).nil?
      id = Relationship.find_by(subordinate: self).superior_id
      Politician.find(id)
    end
  end



  def save_state
    # fetch the superior ID from the object
    superior_id = self.superior.id

    # initialize an empty array for subordinates id
    sub_ids = []

    # Start the iteration off the object active relationships
    self.active_relationships.each do |subordinate|
      # push into the array all subordinates ids
      sub_ids << subordinate.subordinate_id
    end

    # start the iteration off the subordinates ids array
    sub_ids.each do |subordinate|

      # Initiate the OldReplica Construtor
      # this will serve as a way to replicate the relationships before
      # destroy them permanently from the Relationship model
      OldReplica.create(superior: superior_id,
                        subordinate: subordinate, politician_id: self.id)
    end

    # destroy all relationships associated with the object
    self.active_relationships.destroy_all

    # destroy the object id(aka subordinate_id) from the superior object
    superior.active_relationships.where(subordinate: self.id).destroy_all


    # Now that every possible relationship that this object once had
    # is cleared its time to assign the new superiors for the subordinates
    # that just lost their superior
    # to do that we can go up in tier and check who remains, if there's one
    # or more superiors remaining we compare them by house years and see who
    # has it higher







  end







  def recover_state
    if self.active_relationships.empty?
      id = self.id
      replicas_array = []
      subordinates_id = []

      OldReplica.where(politician_id: id).each do |replica|
        replicas_array << replica
      end

      replicas_array.each do |replica|
        subordinates_id << replica
      end

      subordinates_id.each do |subordinate|
        byebug
        self.active_relationships.create(superior_id: id, subordinate_id: subordinate.subordinate)
      end
    end
  end
end
