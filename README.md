# Holy Batman!

A nostalgic quote generator celebrating the campy brilliance of the 1960s Batman TV show. Get a random "Holy ___!" exclamation from Robin every time you visit, complete with shareable permalinks and social media-ready previews.

## Features

- **Random Quote Display** - Fresh "Holy ___!" quote on every page load
- **Unique Permalinks** - Share your favorite quotes with friends
- **One-Click Copy** - Instantly copy permalink to clipboard
- **Social Media Ready** - Dynamic Open Graph images for rich link previews
- **Kitschy Design** - Authentic 60s Batman aesthetic with BAM and POW graphics

## Tech Stack

- **Ruby** 3.4.7
- **Rails** Rails Edge (latest version from Github)
- **Database** SQLite
- **Frontend** Hotwire (Turbo + Stimulus) + Tailwind CSS
- **Deployment** Kamal + Docker

## Setup

### Prerequisites

- Ruby 3.4.7
- Rails Edge
- Docker (for deployment)

### Local Development

```bash
# Install dependencies
bundle install

# Setup database
bin/rails db:setup

# Start development server
bin/dev
```

Visit `http://localhost:3060`

### Development Setup with puma-dev

For a better development experience with multiple local projects use `puma-dev`:

1. Install puma-dev: `brew install puma/puma/puma-dev`
2. Setup system domains: `sudo puma-dev -setup`
3. Install as service **(with localhost domain)**: `puma-dev -install -d localhost`
4. Configure project: `echo 3060 > ~/.puma-dev/holy`
5. Start development server: `bin/dev`
6. Visit `https://holy.localhost` (automatic HTTPS!)

## Deployment

This application uses Kamal for deployment:

```bash
# Configure your deployment
# Edit config/deploy.yml with your server details

# Deploy to production
kamal deploy
```

## Project Structure

- `agent-os/product/` - Product documentation (mission, roadmap, tech stack)
- `app/models/` - Quote model and business logic
- `app/controllers/` - Quote display and permalink handling
- `app/views/` - Templates with Hotwire integration
- `app/javascript/` - Stimulus controllers for interactivity

## License

This is a fun tribute project celebrating the 1960s Batman TV series; no license assumed or required.

## Contributing

This is a personal fun project; I'm not interested in managing an open source project... but if you feel really strongly, open a friendly issue or pull-request and we can chat :)
