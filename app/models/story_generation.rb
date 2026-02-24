# frozen_string_literal: true

class StoryGeneration < ApplicationRecord
  belongs_to :book
  has_many :page_generations, dependent: :destroy
  has_many :character_extractions, dependent: :destroy

  enum :status, {
    pending: 0,
    analyzing_drawings: 1,
    generating_story: 2,
    generating_illustrations: 3,
    completed: 4,
    failed: 5
  }, prefix: true

  validates :book, presence: true
  validates :status, presence: true

  scope :recent, -> { order(created_at: :desc) }
  scope :completed, -> { where(status: :completed) }
  scope :failed, -> { where(status: :failed) }
  scope :in_progress, -> { where(status: [ :pending, :analyzing_drawings, :generating_story, :generating_illustrations ]) }

  def total_pages
    page_generations.count
  end

  def completed_pages
    page_generations.status_completed.count
  end

  def failed_pages
    page_generations.status_failed.count
  end

  def progress_percentage
    return 0 if total_pages.zero?

    (completed_pages.to_f / total_pages * 100).round
  end

  def mark_as_completed!
    update!(status: :completed, completed_at: Time.current)
  end

  def mark_as_failed!(error_message)
    update!(status: :failed, error_message: error_message, completed_at: Time.current)
  end

  def all_pages_completed?
    page_generations.any? && page_generations.all?(&:status_completed?)
  end

  def has_failures?
    page_generations.status_failed.any?
  end
end
