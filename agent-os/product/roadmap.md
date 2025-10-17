# Product Roadmap

1. [x] Quote Model & Database Seeding — Create Quote model with fields for text and context, then seed the database with a comprehensive collection of Robin's iconic "Holy ___" exclamations from the 1960s Batman TV series. Include validation and ensure quotes are unique. `S`

2. [x] Basic Quote Display Page — Build the core landing page that displays a random quote from the database using Rails views and Hotwire Turbo. Include basic styling with dark background and quote text prominently displayed. `XS`

3. [ ] Deployment Configuration — Set up Kamal deployment configuration with proper environment variables, health checks, and SSL certificates. Deploy the working application to production with a custom domain. Include documentation for deployment process. `M`

4. [ ] Kitschy Visual Design System — Implement the full retro 1960s Batman aesthetic with Tailwind CSS including comic book graphics ("BAM", "POW"), bright accent colors, custom typography, and responsive layout that works across all devices. `S`

5. [ ] Unique Permalinks for Quotes — Generate SEO-friendly URLs for each quote (e.g., /quotes/holy-heart-failure) using slugification. Update routing and controller to handle both random quote display and specific quote lookup by slug. `S`

6. [ ] Clipboard Copy Functionality — Add Stimulus controller for one-click permalink copying with visual feedback (tooltip or flash message) when the copy is successful. Include fallback for browsers without clipboard API support. `XS`

7. [ ] Dynamic Open Graph Image Generation — Implement server-side image generation that creates social media preview images for each quote permalink. Images should feature the quote text with the Batman aesthetic styling. Use a library like ImageMagick or a Rails gem for image generation. `M`

8. [ ] Open Graph Meta Tags — Add dynamic Open Graph and Twitter Card meta tags to quote permalink pages so shared links display rich previews with the generated images. Include proper title, description, and image URL tags. `XS`

9. [ ] Quote Refresh Button — Add a Turbo-powered button that fetches and displays a new random quote without page reload. Include smooth transition animations for quote changes. `XS`

> Notes
> - Each item represents an end-to-end functional and testable feature
> - Order prioritizes getting core functionality working, then optimizing and deploying early
> - All features build incrementally toward the complete vision in mission.md
