# frozen_string_literal: true

class CharacterExtraction < ApplicationRecord
  belongs_to :drawing
  belongs_to :story_generation

  enum :status, {
    pending: 0,
    analyzing: 1,
    completed: 2,
    failed: 3
  }, prefix: true

  validates :drawing, presence: true
  validates :story_generation, presence: true
  validates :drawing_id, uniqueness: { scope: :story_generation_id }

  scope :completed_extractions, -> { status_completed }

  def mark_as_completed!(character_data)
    update!(
      status: :completed,
      character_name: character_data[:character_name],
      description: character_data[:description],
      color_palette: character_data[:color_palette],
      proportions: character_data[:proportions]
    )
  end

  def mark_as_failed!(error_message)
    update!(status: :failed)
    story_generation.update(error_message: error_message)
  end

  def visual_summary
    return nil unless status_completed?

    {
      name: character_name,
      description: description,
      colors: color_palette,
      proportions: proportions
    }
  end
end
