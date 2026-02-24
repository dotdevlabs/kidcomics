class ChildProfile < ApplicationRecord
  belongs_to :family_account
  has_one_attached :avatar
  has_many :books, dependent: :destroy

  validates :name, presence: true
  validates :age, presence: true, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 18 }
  validate :avatar_validation

  # Age groups for UI customization
  def age_group
    case age
    when 0..6
      :young
    when 7..12
      :middle
    else
      :teen
    end
  end

  private

  def avatar_validation
    return unless avatar.attached?

    if avatar.blob.byte_size > 5.megabytes
      errors.add(:avatar, "is too large (maximum is 5 MB)")
    end

    acceptable_types = [ "image/jpeg", "image/png", "image/gif", "image/webp" ]
    unless acceptable_types.include?(avatar.blob.content_type)
      errors.add(:avatar, "must be a JPEG, PNG, GIF, or WebP")
    end
  end
end
