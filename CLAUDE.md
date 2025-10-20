# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

完全自作のポートフォリオサイト (Fully custom-built portfolio site) - A personal portfolio website showcasing articles and projects with a like/engagement system.

## Tech Stack

- **Framework**: Ruby on Rails 8.0.3
- **Ruby**: 3.4.3
- **Database**: PostgreSQL 16 with multiple databases for different concerns
- **Frontend**: Hotwire (Turbo + Stimulus), vanilla CSS, importmap for JS
- **Deployment**: Docker Compose with Nginx reverse proxy
- **Target Environment**: ChromeOS Debian virtual machine

## Database Architecture

Rails 8's multi-database setup is configured with separate databases:
- `primary`: Main application data (likes table)
- `cache`: Solid Cache for Rails.cache
- `queue`: Solid Queue for Active Job
- `cable`: Solid Cable for Action Cable

Each has its own migration path:
- `db/migrate/` - Primary database
- `db/cache_migrate/` - Cache database
- `db/queue_migrate/` - Queue database
- `db/cable_migrate/` - Cable database

## Development Commands

### Setup
```bash
bin/setup              # Initial setup (install dependencies, setup DB)
```

### Running the Application

**Development mode:**
```bash
bin/rails server       # Start Rails server at http://localhost:3000
```

**Production mode (Docker):**
```bash
./deploy.sh            # Build and deploy with Docker Compose
                       # Prompts for RAILS_MASTER_KEY if .env doesn't exist
                       # Accessible at http://penguin.linux.test or http://localhost
```

### Database

```bash
bin/rails db:create    # Create databases
bin/rails db:migrate   # Run migrations for all databases
bin/rails db:prepare   # Create DB if needed, then migrate (used in Docker)
bin/rails db:reset     # Drop, create, and migrate
bin/rails db:seed      # Load seed data
```

### Testing

```bash
bin/rails test                    # Run all tests
bin/rails test:system             # Run system tests (Capybara + Selenium)
bin/rails test test/models/like_test.rb  # Run single test file
```

### Code Quality

```bash
bin/rubocop                       # Run RuboCop linter
bin/rubocop -a                    # Auto-fix offenses
bin/brakeman                      # Security vulnerability scanner
```

### Assets & JavaScript

```bash
bin/importmap pin package_name    # Add JS package via importmap
bin/importmap json                # View importmap configuration
```

### Docker Operations

```bash
docker compose up -d              # Start containers in background
docker compose down               # Stop and remove containers
docker compose logs -f            # View logs (follow mode)
docker compose ps                 # Check container status
docker compose restart            # Restart all services
docker compose build              # Rebuild images
```

## Application Architecture

### Controllers

- `PagesController` - Static pages (home)
- `ArticlesController` - Article views (index, individual articles like rails_deployment)
- `LikesController` - JSON API for like/engagement system
  - `show`: GET `/likes/:page_identifier` - Returns like count
  - `create`: POST `/likes/increment` - Increments like count for page
  - Note: Skips CSRF verification for POST endpoint

### Models

- `Like` - Tracks engagement per page
  - `page_identifier`: Unique identifier for each page
  - `count`: Number of likes
  - `Like.increment_for(page_id)`: Class method to atomically increment likes

### Frontend

- **Hotwire**: Uses Turbo for SPA-like navigation
- **Stimulus**: JavaScript controllers in `app/javascript/controllers/`
- **Vanilla CSS**: Stylesheets in `app/assets/stylesheets/`
- **Like functionality**: Implemented in `app/javascript/likes.js` for client-side interactions

### Routes

The application uses simple RESTful routes:
- Root: `pages#home`
- Articles: `/articles/index`, `/articles/rails-deployment`
- Likes API: `/likes/:page_identifier` (GET), `/likes/increment` (POST)

## Production Configuration

### Environment Variables

Required for production:
- `RAILS_MASTER_KEY`: Decrypt credentials.yml.enc
- `DATABASE_URL`: Auto-configured in docker-compose.yml

### Docker Architecture

Three-container setup:
1. **postgres**: PostgreSQL 16 (Alpine) with health checks
2. **web**: Rails app (waits for DB health, runs migrations, starts server)
3. **nginx**: Reverse proxy serving on port 80

The web container runs `bin/rails db:prepare` on startup to ensure databases are ready.

## Key Patterns

### Like System Implementation

The like system is designed for simple page engagement tracking:
1. Each page has a unique `page_identifier`
2. Client-side JS (`likes.js`) handles UI updates and API calls
3. `LikesController` provides JSON API endpoints
4. `Like.increment_for` ensures atomic increments with `increment!`
5. Creates record on first like with `find_or_create_by`

### View Organization

- `app/views/layouts/application.html.erb` - Main layout
- `app/views/pages/` - Static pages
- `app/views/articles/` - Article content
- `app/views/shared/` - Shared partials

## Testing Approach

Standard Rails testing with:
- **Minitest**: Default Rails test framework
- **Capybara + Selenium**: System tests in `test/system/`
- **Fixtures**: Test data in `test/fixtures/`
- Test helper configured in `test/test_helper.rb`

## ブログページを作りたい

/blog にブログ記事一覧ページを作成する。記事は、Markdownで書かれたファイルを読み込み、タイトルを表示する。記事の詳細ページも作成し、クリックすると全文が読めるようにする。

### 検討
- 記事のモデルはarticleが良いか。blogか？
- 記事の保存はDBにする
- MarkdownのパースにはRedcarpetを使う
- ルーティングは /blog と /blog/:id にする?
- ブログにはカテゴリもつけたい

