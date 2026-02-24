class User < ApplicationRecord
  has_secure_password

  has_one :family_account, foreign_key: :owner_id, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }

  before_save :downcase_email

  private

  def downcase_email
    self.email = email.downcase if email.present?
  end
end
