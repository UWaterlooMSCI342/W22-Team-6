class Report < ApplicationRecord
    validates_presence_of :reporter_id
    validates_presence_of :reportee_id
    validates_presence_of :priority
    validates :priority, :inclusion => 0..2
    validates_presence_of :description
    validates_length_of :description, :maximum => 2048
end
