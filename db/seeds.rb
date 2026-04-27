restaurant = Restaurant.create!(
  name: "Warung Bu Sari",
  subdomain: "warung-bu-sari",
  slug: "warung-bu-sari",
  phone: "08123456789",
  address: "Jl. Merdeka No. 1",
  status: :active
)

restaurant.users.create!(
  name: "Bu Sari",
  email: "sari@test.com",
  password: "password123",
  role: :owner
)
