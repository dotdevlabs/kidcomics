class FamilyAccount < ApplicationRecord
  belongs_to :owner, class_name: "User"
  has_many :child_profiles, dependent: :destroy

  validates :name, presence: true

  # Get all books across all child profiles
  def all_books
    Book.joins(:child_profile).where(child_profiles: { family_account_id: id })
  end

  # Family-wide book statistics
  def family_book_statistics
    books = all_books
    {
      total: books.count,
      drafts: books.drafts.count,
      published: books.published.count,
      favorites: books.favorited.count,
      total_views: books.sum(:view_count)
    }
  end
end
