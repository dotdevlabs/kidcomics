class FamilyAccount < ApplicationRecord
  belongs_to :owner, class_name: "User"
  has_many :child_profiles, dependent: :destroy

  validates :name, presence: true
end
