class User < ApplicationRecord
  has_secure_password

  has_one :family_account, foreign_key: :owner_id, dependent: :destroy
  has_many :admin_actions, foreign_key: :admin_user_id, dependent: :destroy

  enum :role, { user: 0, admin: 1 }, default: :user

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }

  scope :admins, -> { where(role: :admin) }
  scope :regular_users, -> { where(role: :user) }
  scope :recent, -> { order(created_at: :desc) }

  before_save :downcase_email

  private

  def downcase_email
    self.email = email.downcase if email.present?
  end
end
