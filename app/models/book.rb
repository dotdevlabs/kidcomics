class Book < ApplicationRecord
  belongs_to :child_profile
  has_many :drawings, -> { order(position: :asc) }, dependent: :destroy

  validates :title, presence: true
  validates :status, presence: true, inclusion: { in: %w[draft published] }

  enum :status, { draft: "draft", published: "published" }, default: :draft

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :published, -> { where(status: "published") }
  scope :drafts, -> { where(status: "draft") }
end
