class Politician < ApplicationRecord

has_many :active_relationships, class_name:  "Relationship",
                                foreign_key: "superior_id",
                                dependent:   :destroy

has_many :oldreplicas
has_many :events


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

  def event_locked
    # creates a "locked" event
    events.create(date: Time.now, locked: true)
  end

  def event_unlocked
    # creates an "unlocked" event
    events.create(date: Time.now, locked: false)
  end

  def is_locked?
    # the last event in the DB tells us if he is locked or not
    if events_empty?
      false
    else
      events.last.locked == true
    end
  end

  def events_empty?
    # check if events array is empty
    # this is needed for the first time an event is created
    events.empty?
  end

  def save_state
    # for the first time the politician will have no events
    if self.events_empty?
      # create a locked event
      event_locked
      # call the set_locked method
      set_locked
    else
      # call set_locked and event locked if self IS NOT locked
      set_locked && event_locked if !self.is_locked?
    end
  end

  def recover_state
    # check if relationships are empty because they are destroyed
    # everytime the object goes to jail
    #                       AND
    # check if he is indeed locked
    if self.active_relationships.empty? && self.is_locked?
      # call the set_locked
      set_unlocked
      # create a locked event
      event_unlocked
    end
  end

  private

  def set_locked
    # get the superior ID
    superior_id = self.superior.id
    # create an empty array that will be filled with subordinates IDS
    sub_ids = []

    self.active_relationships.each do |subordinate|
      # push into the array the subordinates ids
      sub_ids << subordinate.subordinate_id
    end

    sub_ids.each do |subordinate|

      # Initiate the OldReplica Construtor
      # this will serve as a way to replicate the relationships before
      # destroying them  from the Relationship model
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
    # empty array that will be filled with subordinates house years
    # this is a way for us to validate who shall be the next Superior
    house_years_array = []

    # check if the superior doesn't have any active relationship / subordinates
    if superior.active_relationships.empty?
      sub_ids.each do |id|
        # for each subordinate ID find his house years and push
        # into the array
        house_years_array << Politician.find(id).house_years
        # add those subordinates to the Superior
        superior.add_subordinate(Politician.find(id))
      end
    else
      # if the superior still has direct subordinates
      superior.active_relationships.each do |relationship|
        # same process as before
        house_years_array << relationship.subordinate.house_years
      end

      # start a new_director with nil
      new_director = nil

      superior.active_relationships.each do |relationship|
        # check who has the higher house years by matching with the last value
        # of the array
        if relationship.subordinate.house_years == house_years_array.sort!.last
          # save the one that will be the new director of the self subordinates
          new_director = relationship.subordinate
        end
      end

      sub_ids.each do |id|
        # establish the new relationships for the new director
        new_director.active_relationships.create(subordinate_id: id)
      end
    end
  end

  def set_unlocked

    id = self.id
    # check who is his superior
    # the hierarchy of this db only allows for one subordinate to have one
    # direct director so all instances of OldReplicas will share the same
    # superior ID
    superior_id = OldReplica.where(politician_id: id).first.superior
    # set the replicas array
    replicas_array = []
    # set the subordinates array
    subordinates_id = []


    OldReplica.where(politician_id: id).each do |replica|
      # get all the relationships replicas and push them into the array
      replicas_array << replica

    end

    replicas_array.each do |replica|
      # get the subordinates IDS of the replica ONLY if they aren't locked
      # this is needed or yet we estabilish relationships with politicians that
      # are locked..
      subordinates_id << replica.subordinate if !Politician.find(replica.subordinate).is_locked? || Politician.find(replica.subordinate).events_empty?

    end

    # TODO
    subordinates_id.each do |subordinate|

      # FOR EVERY SUBORDINATE DESTROY THE ACTIVE RELATIONSHIPS
      Relationship.where(subordinate: subordinate).destroy_all
      # FOR EVERY SUBORDINATE SET THE SELF ACTIVE RELATIONSHIPS
      self.active_relationships.create(superior_id: id, subordinate_id: subordinate)
      # CHECK IF THE PREVIOUS BOSS IS LOCKED OR NOT
    end

    if Politician.find(superior_id).is_locked?
      # check who is the superior of the superior
      sup_id = OldReplica.where(politician_id: superior_id).last.superior
      # check his subordinates
      new_director = Relationship.where(superior: sup_id)[0].subordinate_id
      Politician.find(new_director).add_subordinate(self)
    else

      #THIS PART IS WRONG!

      #check who is the superior of the superior
      sup_id = Relationship.where(subordinate: superior_id).first.superior.id

      house_years_array = []
      sub_ids = []

      Politician.find(sup_id).active_relationships.each do |relationship|
        house_years_array << relationship.subordinate.house_years  if !relationship.subordinate.is_locked?
        sub_ids << relationship.subordinate.id if !relationship.subordinate.is_locked?
      end

      new_director = nil

      Politician.find(sup_id).active_relationships.each do |relationship|
        # check who has the higher house years by matching with the last value
        # of the array
        if relationship.subordinate.house_years == house_years_array.sort!.last
          # save the one that will be the new director of the self subordinates
          new_director = relationship.subordinate
        end
      end

      Politician.find(new_director).add_subordinate(self)
    end
  end
end


    # subordinates_id.each do |subordinate|
    #   # destroy all live relationships related to the specific subordinate
    #   Relationship.where(subordinate: subordinate).destroy_all
    #   # set the active relationships as they were before being locked
    #   self.active_relationships.create(superior_id: id, subordinate_id: subordinate)




    #   # set the previous superior before being locked
    #   Politician.find(superior_id).add_subordinate(self)
    # end
