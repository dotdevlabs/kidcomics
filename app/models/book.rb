class Book < ApplicationRecord
  belongs_to :child_profile
  has_many :drawings, -> { order(position: :asc) }, dependent: :destroy
  has_many :story_generations, dependent: :destroy
  has_many :page_generations, dependent: :destroy
  has_one_attached :cover_image

  validates :title, presence: true
  validates :status, presence: true, inclusion: { in: %w[draft published] }
  validates :edit_mode, presence: true, inclusion: { in: %w[parent_only shared] }

  # Callbacks
  before_validation :ensure_title, on: :create

  enum :status, { draft: "draft", published: "published" }, default: :draft
  enum :moderation_status, { pending_review: 0, approved: 1, flagged: 2, rejected: 3 }, default: :pending_review, prefix: :moderation

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :oldest, -> { order(created_at: :asc) }
  scope :by_title, -> { order(title: :asc) }
  scope :by_popularity, -> { order(view_count: :desc, created_at: :desc) }
  scope :published, -> { where(status: "published") }
  scope :drafts, -> { where(status: "draft") }
  scope :favorited, -> { where(favorited: true) }
  scope :ai_enabled, -> { where(ai_generation_enabled: true) }
  scope :needs_moderation, -> { where(moderation_status: [ :pending_review, :flagged ]) }
  scope :search_by_title, ->(query) { where("title ILIKE ?", "%#{sanitize_sql_like(query)}%") if query.present? }
  scope :created_between, ->(start_date, end_date) {
    where(created_at: start_date.beginning_of_day..end_date.end_of_day) if start_date.present? && end_date.present?
  }
  scope :created_after, ->(date) { where("created_at >= ?", date.beginning_of_day) if date.present? }
  scope :created_before, ->(date) { where("created_at <= ?", date.end_of_day) if date.present? }
  scope :recently_edited, -> { where.not(last_edited_at: nil).order(last_edited_at: :desc) }
  scope :parent_only_edit, -> { where(edit_mode: "parent_only") }
  scope :shared_edit, -> { where(edit_mode: "shared") }

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

  # Editor methods
  def editable_by?(user)
    return true if edit_mode == "shared"
    return true if edit_mode == "parent_only" && child_profile.family_account.owner == user

    false
  end

  def update_last_edited!
    update!(last_edited_at: Time.current)
  end

  def pages
    drawings
  end

  def cover_page
    drawings.find_by(is_cover: true)
  end

  private

  def ensure_title
    return if title.present?

    # Generate a default title based on the child's name or a creative placeholder
    if child_profile&.name.present?
      self.title = "#{child_profile.name}'s Story"
    else
      self.title = "My Story"
    end
  end
end
