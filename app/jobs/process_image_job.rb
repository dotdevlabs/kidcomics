class ProcessImageJob < ApplicationJob
  queue_as :default

  def perform(drawing_id)
    drawing = Drawing.find_by(id: drawing_id)
    return unless drawing
    return if drawing.processing_status_processed?

    drawing.update_column(:processing_status, Drawing.processing_statuses[:processing])
    DrawingImageProcessor.new(drawing).process!
  rescue DrawingImageProcessor::ProcessingError => e
    drawing&.update_column(:processing_status, Drawing.processing_statuses[:failed])
    Rails.logger.error("[ProcessImageJob] Drawing##{drawing_id} failed: #{e.message}")
  end
end
