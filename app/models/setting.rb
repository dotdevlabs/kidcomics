class Setting < ApplicationRecord
  validates :key, presence: true, uniqueness: true

  # Get a setting value by key with optional default
  def self.get(key, default = nil)
    setting = find_by(key: key)
    return default unless setting

    case setting.value_type
    when "boolean"
      setting.value == "true"
    when "integer"
      setting.value.to_i
    when "float"
      setting.value.to_f
    else
      setting.value
    end
  end

  # Set a setting value by key
  def self.set(key, value, description: nil)
    setting = find_or_initialize_by(key: key)
    setting.value = value.to_s
    setting.value_type = determine_type(value)
    setting.description = description if description
    setting.save!
    setting
  end

  # Check if a setting exists and has a value
  def self.exists?(key)
    find_by(key: key)&.value.present?
  end

  # Postmark-specific settings
  def self.postmark_configured?
    get("postmark_api_key").present?
  end

  def self.postmark_api_key
    get("postmark_api_key")
  end

  def self.postmark_from_email
    get("postmark_from_email", "noreply@kidcomics.app")
  end

  private

  def self.determine_type(value)
    case value
    when TrueClass, FalseClass
      "boolean"
    when Integer
      "integer"
    when Float
      "float"
    else
      "string"
    end
  end
end
