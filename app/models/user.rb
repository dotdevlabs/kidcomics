class User < ApplicationRecord
  has_secure_password validations: false

  has_one :family_account, foreign_key: :owner_id, dependent: :destroy
  has_many :admin_actions, foreign_key: :admin_user_id, dependent: :destroy

  enum :role, { user: 0, admin: 1 }, default: :user

  validates :name, presence: true, unless: :onboarding_in_progress?
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 6 }, if: :should_validate_password?

  scope :admins, -> { where(role: :admin) }
  scope :regular_users, -> { where(role: :user) }
  scope :recent, -> { order(created_at: :desc) }

  before_save :downcase_email
  before_create :generate_verification_token

  # Email verification methods
  def generate_verification_token
    self.verification_token = SecureRandom.urlsafe_base64(32)
  end

  def verify_email!
    update!(email_verified: true, verification_token: nil)
  end

  def send_verification_email
    update!(verification_sent_at: Time.current)
    UserMailer.verification_email(self).deliver_later
  end

  def verification_token_expired?
    verification_sent_at && verification_sent_at < 24.hours.ago
  end

  def onboarding_in_progress?
    !onboarding_completed? && !new_record?
  end

  private

  def downcase_email
    self.email = email.downcase if email.present?
  end

  def should_validate_password?
    # Validate password if it's a new record and password is provided
    # OR if it's an existing record and password is being changed
    (new_record? && password.present?) || (!new_record? && !password.nil?)
  end
end
