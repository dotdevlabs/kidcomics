# frozen_string_literal: true

class PageGeneration < ApplicationRecord
  belongs_to :story_generation
  belongs_to :book

  enum :status, {
    pending: 0,
    generating: 1,
    completed: 2,
    failed: 3
  }, prefix: true

  validates :story_generation, presence: true
  validates :book, presence: true
  validates :page_number, presence: true, uniqueness: { scope: :story_generation_id }
  validates :retry_count, numericality: { greater_than_or_equal_to: 0 }

  scope :ordered, -> { order(:page_number) }
  scope :failed_retriable, -> { status_failed.where("retry_count < ?", Rails.application.config.ai.max_retries) }

  MAX_RETRIES = 3

  def can_retry?
    status_failed? && retry_count < MAX_RETRIES
  end

  def increment_retry_count!
    increment!(:retry_count)
  end

  def mark_as_completed!(generation_time:, cost_cents:)
    update!(
      status: :completed,
      generation_time_seconds: generation_time,
      cost_cents: cost_cents,
      error_message: nil
    )
  end

  def mark_as_failed!(error_message)
    update!(
      status: :failed,
      error_message: error_message
    )
  end

  def reference_drawings
    return Drawing.none if reference_drawing_ids.blank?

    Drawing.where(id: reference_drawing_ids)
  end
end
