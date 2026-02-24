class AdminAction < ApplicationRecord
  belongs_to :admin_user, class_name: "User", foreign_key: :admin_user_id
  belongs_to :target, polymorphic: true, optional: true

  validates :admin_user_id, presence: true
  validates :action_type, presence: true

  scope :recent, -> { order(created_at: :desc) }
  scope :by_action_type, ->(type) { where(action_type: type) if type.present? }
  scope :by_admin, ->(admin_id) { where(admin_user_id: admin_id) if admin_id.present? }
  scope :for_target, ->(target) { where(target: target) if target.present? }

  # Class method to log admin actions
  def self.log(admin:, action:, target: nil, details: {}, ip: nil)
    create!(
      admin_user: admin,
      action_type: action,
      target: target,
      details: details,
      ip_address: ip
    )
  end
end
