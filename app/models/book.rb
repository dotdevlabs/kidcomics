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
  scope :oldest, -> { order(created_at: :asc) }
  scope :by_title, -> { order(title: :asc) }
  scope :by_popularity, -> { order(view_count: :desc, created_at: :desc) }
  scope :published, -> { where(status: "published") }
  scope :drafts, -> { where(status: "draft") }
  scope :favorited, -> { where(favorited: true) }
  scope :ai_enabled, -> { where(ai_generation_enabled: true) }
  scope :search_by_title, ->(query) { where("title ILIKE ?", "%#{sanitize_sql_like(query)}%") if query.present? }
  scope :created_between, ->(start_date, end_date) {
    where(created_at: start_date.beginning_of_day..end_date.end_of_day) if start_date.present? && end_date.present?
  }
  scope :created_after, ->(date) { where("created_at >= ?", date.beginning_of_day) if date.present? }
  scope :created_before, ->(date) { where("created_at <= ?", date.end_of_day) if date.present? }

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

  # Bookshelf methods
  def increment_view_count!
    increment!(:view_count)
  end

  def toggle_favorite!
    update!(favorited: !favorited)
  end
end
