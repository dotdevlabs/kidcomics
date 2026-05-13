class DrawingImageProcessor
  class ProcessingError < StandardError; end

  HEIC_TYPES = %w[image/heic image/heif].freeze

  def initialize(drawing)
    @drawing = drawing
  end

  def process!
    input_tempfile = download_image
    output_tempfile = Tempfile.new([ "processed_#{@drawing.id}", ".jpg" ])

    begin
      img = Vips::Image.new_from_file(input_tempfile.path)
      img = img.autorot
      img = trim_whitespace(img)
      img = normalize_brightness(img)
      img = img.gaussblur(0.5)
      img.write_to_file(output_tempfile.path, Q: 90)

      reattach(output_tempfile.path)
      @drawing.update_column(:processing_status, Drawing.processing_statuses[:processed])
    rescue StandardError => e
      @drawing.update_column(:processing_status, Drawing.processing_statuses[:failed])
      Rails.logger.error("[DrawingImageProcessor] Failed for Drawing##{@drawing.id}: #{e.message}")
      raise ProcessingError, e.message
    ensure
      input_tempfile.close
      input_tempfile.unlink
      output_tempfile.close
      output_tempfile.unlink
    end
  end

  private

  def download_image
    ext = File.extname(@drawing.image.blob.filename.to_s).downcase
    ext = ".jpg" if ext.empty?
    tempfile = Tempfile.new([ "drawing_#{@drawing.id}", ext ])
    tempfile.binmode
    @drawing.image.blob.download { |chunk| tempfile.write(chunk) }
    tempfile.rewind
    tempfile
  end

  def reattach(path)
    @drawing.image.attach(
      io: File.open(path, "rb"),
      filename: "drawing_#{@drawing.id}_processed.jpg",
      content_type: "image/jpeg"
    )
  end

  def trim_whitespace(img)
    left, top, width, height = img.find_trim(background: [ 255, 255, 255 ], threshold: 20)
    return img unless width > 10 && height > 10

    img.crop(left, top, width, height)
  rescue StandardError
    img
  end

  def normalize_brightness(img)
    min_val = img.min
    max_val = img.max
    return img if (max_val - min_val) < 1.0

    scale = 255.0 / (max_val - min_val)
    offset = -min_val * scale
    img.linear([ scale ] * img.bands, [ offset ] * img.bands).cast(:uchar)
  rescue StandardError
    img
  end
end
