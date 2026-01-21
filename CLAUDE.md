# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Quotes Collection is a WordPress plugin for collecting, managing, and displaying quotes. It provides a sidebar widget, Gutenberg blocks, shortcodes, and a template function for displaying quotes.

## Build Commands

```bash
# Build without version bump
./build.sh --no-bump

# Build with patch version bump (default)
./build.sh

# Build with minor/major version bump
./build.sh --minor
./build.sh --major

# Or use npm
npm run build        # no bump
npm run build:patch  # patch bump
npm run release      # same as build:patch
```

The build creates a ZIP file in `dist/` for WordPress installation. The ZIP contains a `quotes-collection/` folder (no version in folder name) - this is required for WordPress to recognize plugin updates. Version is kept in the PHP header only.

## Architecture

### Directory Structure

```
quotes-collection.php    # Main plugin bootstrap, entry point
inc/                     # PHP classes
  class-quotes-collection.php           # Main plugin class, AJAX, script loading
  class-quotes-collection-db.php        # Database CRUD with prepared statements
  class-quotes-collection-quote.php     # Quote data model and rendering
  class-quotes-collection-admin.php     # Admin interface, import/export
  class-quotes-collection-admin-list-table.php  # WP_List_Table for quotes
  class-quotes-collection-widget.php    # Sidebar widget
  class-quotes-collection-shortcode.php # Shortcode handler ([quotcoll])
blocks/                  # Gutenberg blocks
  quotes/                # Block for multiple quotes with filtering/paging
  random-quote/          # Block for random quotes with AJAX refresh
js/                      # Frontend JavaScript (AJAX refresh)
css/                     # Stylesheets (frontend and admin)
uninstall.php            # Cleanup on deletion (excluded from builds)
```

## Database

Custom table `wp_quotescollection` with fields: quote_id, quote, author, source, tags, public, time_added, time_updated.

All database operations use prepared statements for SQL injection prevention.

## Key Display Methods

1. Sidebar widget (Quotes_Collection_Widget)
2. Shortcodes: `[quotcoll]`, `[quotecoll]` with attributes like `author`, `tags`, `orderby`, `limit`, `ajax_refresh`
3. Gutenberg blocks
4. Template function: `quotescollection_quote()`
