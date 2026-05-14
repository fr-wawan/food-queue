# FoodQueue

[![Ruby](https://img.shields.io/badge/Ruby-4.x-CC342D?style=flat-square&logo=ruby&logoColor=white)](https://www.ruby-lang.org/)
[![Rails](https://img.shields.io/badge/Rails-8.1-CC0000?style=flat-square&logo=rubyonrails&logoColor=white)](https://rubyonrails.org/)
[![MySQL](https://img.shields.io/badge/MySQL-8.0-4479A1?style=flat-square&logo=mysql&logoColor=white)](https://www.mysql.com/)
[![Redis](https://img.shields.io/badge/Redis-7-DC382D?style=flat-square&logo=redis&logoColor=white)](https://redis.io/)
[![Elasticsearch](https://img.shields.io/badge/Elasticsearch-8.13-005571?style=flat-square&logo=elasticsearch&logoColor=white)](https://www.elastic.co/)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)

A multi-tenant REST API for restaurant order management. One Rails instance serves multiple restaurants simultaneously, each isolated by subdomain — built as a learning project mirroring the HungryHub production stack.

## Table of Contents

- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Requirements](#requirements)
- [Setup](#setup)
- [Running Tests](#running-tests)
- [API Reference](#api-reference)
- [Design Decisions](#design-decisions)
- [Project Structure](#project-structure)

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Ruby on Rails 8.1 (API mode) |
| Database | MySQL 8.0 |
| Cache | Redis 7 |
| Search | Elasticsearch 8.13 + Searchkick |
| Background Jobs | Sidekiq |
| Auth | JWT (hybrid stateless + stateful revocation) |
| Authorization | Pundit |
| Serializer | Blueprinter |
| Pagination | Pagy |
| Multi-tenancy | acts_as_tenant (row-level) |
| Testing | RSpec + FactoryBot + shoulda-matchers |
| Containerization | Docker + Compose |

## Architecture

### Multi-tenancy

Row-level tenancy via `acts_as_tenant`. Every domain table has a `restaurant_id` column. The tenant is resolved at authentication time — all subsequent queries in the request are automatically scoped.

```
POST /api/v1/auth/login { subdomain: "warung-bu-sari", email: "...", password: "..." }
→ resolve tenant → all queries WHERE restaurant_id = X
```

### Auth Pattern

Hybrid JWT — stateless verification, stateful revocation.

- Token payload contains `jti` (JWT ID) stored in the `sessions` table
- Logout = delete session row → token immediately invalid regardless of expiry
- Avoids the classic pure-stateless JWT problem where issued tokens can't be revoked

### Caching Strategy

Cache logic lives in the **model layer**, not controllers, via a `cached_for` class method backed by `after_commit` invalidation.

```ruby
Menu.cached_for(restaurant_id)   # key: menus:{id}:v1
MenuItem.cached_for(menu_id)     # key: menu_items:{id}:v1
```

Redis database `/1` for cache, `/0` for Sidekiq — isolated namespaces.

### Authorization

Pundit policies enforce role-based access (owner / staff / cashier) at the action level. All controllers call `authorize` before performing any operation.

| Resource | owner | staff | cashier |
|----------|-------|-------|---------|
| Menu CRUD | ✅ | ✅ | ❌ |
| MenuItem CRUD | ✅ | ✅ | ❌ |
| MenuItem search | ✅ | ✅ | ✅ |
| Order index/show/create | ✅ | ✅ | ✅ |
| Order update status | ✅ | ✅ | ❌ |

## Requirements

- Ruby 3.x
- Bundler
- Docker >= 24.x and Docker Compose >= 2.x (for MySQL, Redis, Elasticsearch)

## Setup

### 1. Clone & Environment

```bash
git clone https://github.com/fr-wawan/food-queue
cd food-queue

cp .env.example .env
# Fill in JWT_SECRET and SECRET_KEY_BASE (see below)
```

### 2. Start Services

Docker is used only for infrastructure — MySQL, Redis, and Elasticsearch. Rails itself runs locally.

```bash
docker compose up -d
```

This starts:
- MySQL 8.0 on port `3307`
- Redis 7 on port `6379`
- Elasticsearch 8.13 on port `9200`

### 3. Install & Boot

```bash
bundle install

bundle exec rails db:prepare

# Index MenuItem data into Elasticsearch
bundle exec rails searchkick:reindex CLASS=MenuItem

# Start Rails
bundle exec rails server

# Start Sidekiq (separate terminal)
bundle exec sidekiq
```

API available at `http://localhost:3000`

### Environment Variables

```env
RAILS_ENV=development
SECRET_KEY_BASE=

DATABASE_URL=mysql2://food_queue:food_queue@127.0.0.1:3307/food_queue_development

REDIS_URL=redis://127.0.0.1:6379/0

ELASTICSEARCH_URL=http://127.0.0.1:9200

JWT_SECRET=
```

Generate secrets:

```bash
rails secret  # for SECRET_KEY_BASE
rails secret  # for JWT_SECRET
```

## Running Tests

```bash
bundle exec rspec
```

```bash
# Specific file
bundle exec rspec spec/requests/api/v1/orders_spec.rb

# With Docker
docker compose exec -e RAILS_ENV=test api bundle exec rails db:prepare
docker compose exec -e RAILS_ENV=test api bundle exec rspec
```

## API Reference

### Base URL

```
http://localhost:3000/api/v1
```

### Authentication

All endpoints except `GET` menus and menu items require a Bearer token.

```
Authorization: Bearer <token>
```

#### Login

```http
POST /api/v1/auth/login
Content-Type: application/json

{
  "subdomain": "warung-bu-sari",
  "email": "owner@example.com",
  "password": "password123"
}
```

```json
{
  "token": "<jwt>",
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "owner@example.com",
    "role": "owner"
  }
}
```

#### Logout

```http
DELETE /api/v1/auth/logout
Authorization: Bearer <token>
```

---

### Menus

| Method | Endpoint | Role Required |
|--------|----------|---------------|
| GET | `/menus` | — |
| GET | `/menus/:id` | — |
| POST | `/menus` | owner, staff |
| PUT | `/menus/:id` | owner, staff |
| DELETE | `/menus/:id` | owner, staff |

#### Create Menu

```http
POST /api/v1/menus
Authorization: Bearer <token>
Content-Type: application/json

{
  "menu": {
    "name": "Makanan",
    "description": "Menu makanan berat",
    "position": 1,
    "status": "active"
  }
}
```

---

### Menu Items

| Method | Endpoint | Role Required |
|--------|----------|---------------|
| GET | `/menus/:menu_id/menu_items` | — |
| GET | `/menu_items/:id` | — |
| GET | `/menu_items/search?q=...` | — |
| POST | `/menus/:menu_id/menu_items` | owner, staff |
| PUT | `/menu_items/:id` | owner, staff |
| DELETE | `/menu_items/:id` | owner, staff |

#### Search Menu Items

```http
GET /api/v1/menu_items/search?q=goreng&page=1&per_page=20
Authorization: Bearer <token>
```

```json
{
  "data": [
    {
      "id": 1,
      "name": "Nasi Goreng",
      "description": "Nasi goreng spesial",
      "price": "25000.0",
      "stock": 10,
      "status": "available"
    }
  ],
  "meta": {
    "total": 2,
    "page": 1,
    "per_page": 20
  }
}
```

Only returns items with `status: available`. Supports partial match — searching `gor` will match `Nasi Goreng`.

#### Create Menu Item

```http
POST /api/v1/menus/1/menu_items
Authorization: Bearer <token>
Content-Type: application/json

{
  "menu_item": {
    "name": "Nasi Goreng",
    "description": "Nasi goreng spesial",
    "price": 25000,
    "stock": 10,
    "status": "available"
  }
}
```

---

### Orders

| Method | Endpoint | Role Required |
|--------|----------|---------------|
| GET | `/orders` | all roles |
| GET | `/orders/:id` | all roles |
| POST | `/orders` | all roles |
| PUT | `/orders/:id` | owner, staff |

#### Order Status Transitions

```
pending → confirmed → preparing → ready → delivered
pending → cancelled
confirmed → cancelled
```

Invalid transitions return `422 Unprocessable Content`.

#### Create Order

```http
POST /api/v1/orders
Authorization: Bearer <token>
Content-Type: application/json

{
  "order": {
    "note": "Tanpa bawang",
    "items": [
      { "menu_item_id": 1, "quantity": 2 },
      { "menu_item_id": 3, "quantity": 1 }
    ]
  }
}
```

```json
{
  "id": 1,
  "order_number": "ORD-20260514-A1B2C3D4",
  "status": "pending",
  "note": "Tanpa bawang",
  "total_price": "50000.0",
  "user": { "id": 1, "name": "John Doe", "role": "staff" },
  "order_items": [
    {
      "id": 1,
      "quantity": 2,
      "unit_price": "25000.0",
      "subtotal": "50000.0",
      "menu_item": { "id": 1, "name": "Nasi Goreng", "price": "25000.0" }
    }
  ]
}
```

Order creation is wrapped in a transaction — if any item has insufficient stock or doesn't exist, the entire order is rolled back.

#### Update Order Status

```http
PUT /api/v1/orders/1
Authorization: Bearer <token>
Content-Type: application/json

{
  "status": "confirmed"
}
```

---

### HTTP Status Codes

| Code | Meaning |
|------|---------|
| 200 | OK |
| 201 | Created |
| 204 | No Content |
| 401 | Unauthorized — missing or invalid token |
| 403 | Forbidden — insufficient role |
| 404 | Not Found |
| 422 | Unprocessable Content — validation or business rule failed |

---

### Error Format

```json
{
  "errors": ["Stock tidak cukup untuk 'Nasi Goreng': diminta 999, tersedia 10"]
}
```

## Design Decisions

### 1. Hybrid JWT Authentication

Pure stateless JWT cannot support logout — once issued, a token is valid until expiry. This project stores a `jti` (JWT ID) in a `sessions` table, enabling immediate revocation on logout without sacrificing stateless verification on every request.

### 2. Row-level Multi-tenancy

`acts_as_tenant` automatically appends `WHERE restaurant_id = X` to all queries after the tenant is set during authentication. No risk of cross-tenant data leaks from a forgotten scope.

### 3. Cache in the Model Layer

Cache logic (`cached_for`, `invalidate_cache`) lives in the model, not the controller. Controllers remain thin. Invalidation is driven by `after_commit` callbacks — no manual cache management needed after mutations.

### 4. Unit Price Snapshot

`order_items.unit_price` stores the price at the time of order creation, not a foreign key to the current price. This ensures historical order data is never affected by future price changes.

### 5. Async Elasticsearch Reindex

`MenuItem` sets `callbacks: false` for Searchkick and delegates reindexing to `ReindexMenuItemJob` via Sidekiq. Keeps write requests fast — search index consistency is eventual, not synchronous.

### 6. Transaction-scoped Order Creation

Order creation, item building, and total calculation happen inside a single `ActiveRecord::Transaction`. Any failure (missing item, insufficient stock, validation error) triggers a full rollback — no partial orders in the database.

## Project Structure

```
app/
├── controllers/
│   ├── application_controller.rb
│   └── api/v1/
│       ├── auth_controller.rb
│       ├── menus_controller.rb
│       ├── menu_items_controller.rb
│       └── orders_controller.rb
├── models/
│   ├── restaurant.rb
│   ├── user.rb
│   ├── session.rb
│   ├── menu.rb
│   ├── menu_item.rb
│   ├── order.rb
│   └── order_item.rb
├── policies/
│   ├── application_policy.rb
│   ├── menu_policy.rb
│   ├── menu_item_policy.rb
│   └── order_policy.rb
├── blueprints/
│   ├── user_blueprint.rb
│   ├── menu_blueprint.rb
│   ├── menu_item_blueprint.rb
│   ├── order_blueprint.rb
│   └── order_item_blueprint.rb
├── jobs/
│   ├── reindex_menu_item_job.rb
│   └── notify_order_job.rb
├── services/
│   └── jwt_service.rb
├── errors/
│   └── insufficient_stock_error.rb
└── controllers/concerns/
    └── authenticatable.rb
```

## License

This project is open-sourced software licensed under the [MIT license](LICENSE).
