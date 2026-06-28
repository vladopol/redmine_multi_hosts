# Redmine Multi Hosts

A Redmine plugin that allows running one Redmine installation with multiple hostnames, each with its own branding, email sender, and SMTP settings.

This is a fork of [florianeck/redmine_multi_hosts](https://github.com/florianeck/redmine_multi_hosts) with compatibility fixes for Redmine 4.x / Rails 5.x and new features.

## What's new in this fork

- **Rails 5.x / Redmine 4.x compatibility** — fixed deprecated `before_filter`, `after_filter`, `update_attributes` and migration syntax
- **Per-host SMTP settings** — each host can use its own SMTP server, credentials and sender address
- **Page header branding** — app title is now correctly overridden in all pages including project pages
- **New host UI** — added "New Host" button and form directly in the admin interface
- **Localization** — English and Russian translations

## Requirements

- Redmine 4.x
- Rails 5.2.x

## Installation

```bash
cd /path/to/redmine/plugins
git clone https://github.com/vladopol/redmine_multi_hosts.git
cd /path/to/redmine
bundle exec rake redmine:plugins:migrate RAILS_ENV=production
touch tmp/restart.txt
```

## Setup

After installation, go to **Administration → MultiHosts** and:

1. Click **New Host** to add your default host (or run rake task below)
2. Add additional hosts with their own branding and SMTP settings

Or use rake tasks:

```bash
# Setup default host based on current Redmine settings
bundle exec rake multi_hosts:setup_default_host RAILS_ENV=production

# Add a new host
bundle exec rake "multi_hosts:add_host[https://support.example.com/]" RAILS_ENV=production
```

## Per-host settings

Each host supports:

- **App Title** — custom application name shown in header and emails
- **Default Mail From** — sender email address for notifications
- **SMTP settings** — address, port, user, password, authentication method

## How it works

The plugin detects the current hostname from each HTTP request and applies the corresponding settings:
- Overrides the page header title
- Uses per-host SMTP for outgoing email notifications
- Replaces app title in email subjects and body

## Original plugin

This plugin is based on [redmine_multi_hosts](https://github.com/florianeck/redmine_multi_hosts) by Florian Eck for akquinet.
