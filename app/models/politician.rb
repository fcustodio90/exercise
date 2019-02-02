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

    # set the superior again we can't acess it via superior anymore since
    # we just destroyed the relation. This is necessary because it makes
    # the rest of the code cleaner


    # set the superior again.
    superior = Politician.find(superior_id)


    house_years_array = []

    superior.active_relationships.each do |relationship|
      house_years_array << relationship.subordinate.house_years
    end

    new_director = nil

    superior.active_relationships.each do |relationship|
     if relationship.subordinate.house_years == house_years_array.sort!.last
      new_director = relationship.subordinate
     end
    end

    sub_ids.each do |id|
      new_director.active_relationships.create(subordinate_id: id)
    end
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



    # Now that every possible relationship that this object once had
    # is cleared its time to assign the new superiors for the subordinates
    # that just lost their superior
    # to do that we can go up in tier and check who remains, if there's one
    # or more superiors remaining we compare them by house years and see who
    # has it higher



    #initialize an empty array that will be filled with subordinates objects
    # subordinates_house_years = []

    # superior.active_relationships.each do |relationship|
    #   subordinates_house_years[1] << relationship.subordinate.id if relationship.subordinate != self
    # end

    # # this will be the next superior
    # older_subordinate = subordinates_house_years.sort!.last


    # byebug
    # # set next superior

    # puts 'hello hello hello'
