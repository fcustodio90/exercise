class Relationship < ApplicationRecord
  belongs_to :superior, class_name: "Politician"
  belongs_to :subordinate, class_name: "Politician"

end
