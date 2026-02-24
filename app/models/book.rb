class Book < ApplicationRecord
  belongs_to :child_profile
  has_many :drawings, -> { order(position: :asc) }, dependent: :destroy
  has_many :story_generations, dependent: :destroy
  has_many :page_generations, dependent: :destroy

  validates :title, presence: true
  validates :status, presence: true, inclusion: { in: %w[draft published] }

  enum :status, { draft: "draft", published: "published" }, default: :draft

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :published, -> { where(status: "published") }
  scope :drafts, -> { where(status: "draft") }
  scope :ai_enabled, -> { where(ai_generation_enabled: true) }

  # AI Generation methods
  def current_story_generation
    story_generations.in_progress.last || story_generations.recent.first
  end

  def has_drawings?
    drawings.any?
  end

  def ready_for_ai_generation?
    ai_generation_enabled? && has_drawings?
  end
end
