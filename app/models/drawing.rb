class Drawing < ApplicationRecord
  belongs_to :book
  has_one_attached :image do |attachable|
    attachable.variant :thumb, resize_to_limit: [ 150, 150 ]
    attachable.variant :medium, resize_to_limit: [ 800, 800 ]
    attachable.variant :large, resize_to_limit: [ 1600, 1600 ]
  end
  has_many :character_extractions, dependent: :destroy

  validates :image, presence: true, on: :update
  validates :position, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :tag, inclusion: { in: %w[character background object], allow_nil: true }
  validate :image_validation

  enum :analysis_status, {
    pending: 0,
    analyzing: 1,
    completed: 2,
    failed: 3
  }, prefix: true

  # Callbacks
  before_validation :set_position, on: :create

  # Scopes
  scope :ordered, -> { order(position: :asc) }
  scope :tagged, ->(tag) { where(tag: tag) }
  scope :characters, -> { where(is_character: true) }
  scope :backgrounds, -> { where(is_background: true) }
  scope :analyzed, -> { analysis_status_completed }
  scope :covers, -> { where(is_cover: true) }
  scope :pages, -> { where(is_cover: false) }

  # Text content methods
  def has_text?
    narration_text.present? || dialogue_text.present?
  end

  def combined_text
    [ narration_text, dialogue_text ].compact.join("\n\n")
  end

  private

  def set_position
    return if position.present?
    max_position = Drawing.where(book: book).maximum(:position)
    self.position = (max_position || -1) + 1
  end

  def image_validation
    return unless image.attached?

    if image.blob.byte_size > 10.megabytes
      errors.add(:image, "is too large (maximum is 10 MB)")
    end

    acceptable_types = [ "image/jpeg", "image/jpg", "image/png", "image/heic", "image/heif", "image/webp" ]
    unless acceptable_types.include?(image.blob.content_type)
      errors.add(:image, "must be a JPEG, PNG, HEIC, or WebP")
    end
  end
end
