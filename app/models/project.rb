class Project < ActiveRecord::Base
  include Ownable
  include SubjectCounts
  include Activateable

  has_many :workflows
  has_many :subject_sets
  has_many :classifications
  has_many :subjects
end
