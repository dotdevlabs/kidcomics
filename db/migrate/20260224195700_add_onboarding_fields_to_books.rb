class AddOnboardingFieldsToBooks < ActiveRecord::Migration[8.1]
  def change
    add_column :books, :is_onboarding_book, :boolean, default: false, null: false
  end
end
