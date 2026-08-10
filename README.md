# KidComics

A Rails application that enables children and families to create illustrated stories and comic books through a collaborative, AI-assisted creative platform.

## Getting Started

### Prerequisites

- Ruby 3.3+
- PostgreSQL 14+
- Node.js 18+ (for asset pipeline)
- Bundler

### Setup

1. Clone the repository and navigate to the project directory.

2. Install dependencies:
   ```bash
   bin/setup
   ```

   This script will:
   - Install Ruby gems
   - Set up the PostgreSQL database
   - Create the schema
   - Seed sample data

3. Start the development server:
   ```bash
   bin/rails s
   ```

   The application will be available at `http://localhost:3000`.

### Database

If you need to reset the database:
```bash
bin/rails db:reset
```

Or prepare the database (create if needed):
```bash
bin/rails db:prepare
```

## Internationalization (i18n)

The application supports 7 languages:

- **English** (`en`) — default
- **Spanish** (`es`)
- **French** (`fr`)
- **German** (`de`)
- **Italian** (`it`)
- **Portuguese (Brazil)** (`pt-BR`)
- **Portuguese (Portugal)** (`pt-PT`)

### How Locale Selection Works

The locale is resolved in this order:

1. URL parameter: `?locale=es`
2. User preference: stored in the `users.locale` column
3. Accept-Language header from browser
4. Fallback to English

Users can switch their preferred locale using the locale switcher UI (visible throughout the app), which persists the choice to their account.

### Locale Fallback Chain

- **Portuguese (Portugal)** falls back to Portuguese (Brazil), then English
- **All other locales** fall back directly to English

This ensures users always see content, even if a translation is incomplete.

### Adding New Translation Keys

When adding a new feature:

1. Add the key to `/workspace/config/locales/en.yml` with the English text
2. Use `t("key.path")` in views, controllers, and mailers to reference it

Example:
```erb
<h1><%= t("books.title") %></h1>
```

3. Run the i18n-tasks check to see what needs translation:
   ```bash
   bundle exec i18n-tasks missing
   ```

4. Add the translations to all other locale files under `/workspace/config/locales/`:
   - `de.yml`, `es.yml`, `fr.yml`, `it.yml`, `pt-BR.yml`, `pt-PT.yml`

The check will also highlight unused translations:
```bash
bundle exec i18n-tasks unused
```

### i18n-tasks Configuration

The file `/workspace/.i18n-tasks.yml` defines:
- Base locale: English
- Available locales: all 7 supported languages
- Ignored keys that are dynamically looked up (e.g., `books.statuses.{draft,published}`)

## JSON:API

The application exposes a small JSON:API surface for machine-readable deploy metadata. All JSON:API responses use `Content-Type: application/vnd.api+json`.

The full API spec lives at [`docs/api_spec.yaml`](docs/api_spec.yaml) (OpenAPI 3.0.3). Add new `Api::` endpoints there before shipping them.

### Endpoints

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/status` | Deploy status: build version, commit SHA, DB migration version |

#### `GET /status`

Returns the current deploy state. All attributes are `null` when not set (e.g. in local dev without build args).

```json
{
  "data": {
    "type": "status",
    "id": "current",
    "attributes": {
      "version": "1.2.3",
      "sha": "abc1234",
      "db_version": "20240101120000"
    }
  }
}
```

`version` and `sha` are baked into the Docker image at build time via `BUILD_VERSION` and `COMMIT_SHA` build args. `db_version` is the latest applied schema migration version read at request time.

### Adding New API Endpoints

1. Create a controller under `app/controllers/api/` inheriting from `Api::BaseController`
2. Add the route in `config/routes.rb` inside the `scope module: :api` block
3. Document the path in `docs/api_spec.yaml`
4. The contract test (`test/contracts/api_contract_test.rb`) enforces a two-way bijection between routes and the spec — it will fail if either side is missing

## Testing

Run the test suite:
```bash
bin/rails test
```

This runs all unit, integration, and contract tests. A SimpleCov coverage gate enforces minimum 80% coverage — the report is written to `coverage/` after each run.

Run tests for a specific file:
```bash
bin/rails test test/models/user_test.rb
```

## CI Checks

The project uses a CI pipeline defined in `/workspace/config/ci.rb`. Run all checks locally:

```bash
bin/ci
```

This executes:

1. **Setup** — database preparation
2. **Style** — RuboCop (Ruby linting)
3. **Security** — gem audit, importmap audit, Brakeman code analysis
4. **Tests** — Rails test suite and seed data validation
5. **i18n** — internationalization checks:
   - `missing` — detects keys in code but not in all locale files
   - `unused` — detects keys in locale files not used in code
   - `normalize` — ensures consistent YAML formatting
   - `health` — overall translation coverage report

All checks must pass before merging a PR. The i18n checks ensure translations stay complete and consistent across all supported languages.

## Project Structure

- `/app/controllers` — request handlers and locale resolution logic
- `/app/controllers/api/` — JSON:API controllers (`Api::BaseController`, `Api::StatusController`)
- `/app/models` — data models (User, ChildProfile, Book, etc.)
- `/app/views` — ERB templates with i18n integration
- `/app/mailers` — email templates (UserMailer)
- `/config/locales` — translation files for all 7 languages
- `/db/migrate` — database schema changes
- `/docs/api_spec.yaml` — OpenAPI 3.0.3 spec for all JSON:API endpoints
- `/test` — unit, integration, and system tests
- `/test/contracts/` — spec-driven contract tests enforcing route↔spec bijection

## Development Workflow

1. Create a feature branch
2. Make your changes and write tests
3. Run `bin/ci` to verify all checks pass
4. Create a pull request

For internationalization:
- Always add keys to `en.yml` first
- Use `bundle exec i18n-tasks missing` to identify translation gaps
- Update all locale files before committing

## Additional Resources

- [Rails i18n Guide](https://guides.rubyonrails.org/i18n.html)
- [i18n-tasks Documentation](https://github.com/glebm/i18n-tasks)
