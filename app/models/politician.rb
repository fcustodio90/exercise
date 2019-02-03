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
    events.create(date: Time.now, locked: true)
  end

  def event_unlocked
    events.create(date: Time.now, locked: false)
  end

  def is_locked?
    if events_empty?
      false
    else
      events.last.locked == true
    end
  end

  def events_empty?
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
    byebug
    sub_ids = []
    superior_id = nil

    OldReplica.where(politician: self).each do |replica|
      if !Politician.find(replica.subordinate).is_locked?
        sub_ids << replica.subordinate
        superior_id = replica.superior
      end
    end

    sub_ids.each do |id|
      Relationship.where(subordinate: id).destroy_all
    end

    sub_ids.each do |id|
      self.add_subordinate(Politician.find(id))
    end
    Politician.find(superior_id).add_subordinate(self)
    OldReplica.where(politician: self).destroy_all
  end
end

