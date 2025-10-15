# Tech Stack

## Backend Framework
- **Ruby 3.3.6** - Modern, stable Ruby version with performance improvements
- **Rails 8.0** - Latest Rails with enhanced Hotwire integration and modern defaults

## Database
- **SQLite** - Simple, serverless database perfect for read-heavy quote applications with minimal complexity

## Frontend
- **Hotwire (Turbo + Stimulus)** - Server-rendered HTML with progressive enhancement for dynamic interactions
  - **Turbo** - Fast navigation and partial page updates without full page reloads
  - **Stimulus** - Lightweight JavaScript framework for sprinkles of interactivity (clipboard copy, animations)
- **Tailwind CSS** - Utility-first CSS framework for rapid UI development and custom retro styling

## Deployment
- **Kamal** - Modern deployment tool for Rails applications with zero-downtime deploys
- **Docker** - Containerization for consistent environments across development and production

## Development Tools
- **Rails Development Server** - Built-in development server with hot reloading
- **Tailwind CSS CLI** - Standalone Tailwind build process integrated with Rails asset pipeline

## Image Generation (Future)
- **ImageMagick** or **MiniMagick** - Server-side image generation for dynamic Open Graph preview images

## Monitoring & Analytics (Future)
- **Privacy-respecting analytics** (Fathom, Plausible, or similar) - Page view and share tracking
- **Error monitoring** (likely built-in Rails error handling with log aggregation)

## Architecture Principles
- **Server-side rendering first** - Leverage Rails views and partials for most UI
- **Progressive enhancement** - JavaScript adds interactivity but core features work without it
- **Simple deployment** - Single container, minimal infrastructure complexity
- **Performance through caching** - Rails fragment caching and HTTP caching headers
