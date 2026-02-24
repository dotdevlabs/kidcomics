# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create admin user
admin = User.find_or_create_by!(email: "admin@kidcomics.com") do |user|
  user.name = "Admin User"
  user.password = "password123"
  user.password_confirmation = "password123"
  user.role = :admin
end

puts "✅ Admin user created: #{admin.email} (password: password123)"

# Create a test family account for the admin (optional)
unless admin.family_account.present?
  admin_family = FamilyAccount.create!(
    owner: admin,
    name: "Admin's Family"
  )
  puts "✅ Admin family account created"
end

# Create a regular test user
test_user = User.find_or_create_by!(email: "user@example.com") do |user|
  user.name = "Test User"
  user.password = "password123"
  user.password_confirmation = "password123"
  user.role = :user
end

puts "✅ Test user created: #{test_user.email}"

# Create family account for test user
unless test_user.family_account.present?
  family = FamilyAccount.create!(
    owner: test_user,
    name: "Test Family"
  )

  # Create child profiles
  child1 = ChildProfile.create!(
    family_account: family,
    name: "Emma",
    age: 7
  )

  child2 = ChildProfile.create!(
    family_account: family,
    name: "Jake",
    age: 5
  )

  # Create some test books
  book1 = Book.create!(
    child_profile: child1,
    title: "Emma's Space Adventure",
    description: "A story about Emma exploring space",
    status: "published",
    moderation_status: :pending_review
  )

  book2 = Book.create!(
    child_profile: child2,
    title: "Jake and the Magical Forest",
    description: "Jake discovers a magical forest",
    status: "draft",
    moderation_status: :approved
  )

  book3 = Book.create!(
    child_profile: child1,
    title: "The Dragon's Secret",
    description: "A dragon needs help",
    status: "published",
    moderation_status: :flagged
  )

  puts "✅ Created test family with #{family.child_profiles.count} children and #{Book.where(child_profile: [child1, child2]).count} books"
end

puts "\n🎉 Seed data created successfully!"
puts "📝 Admin credentials: admin@kidcomics.com / password123"
puts "📝 Test user credentials: user@example.com / password123"
