# Redmine Multi Hosts

[Русская версия](README.ru.md)

A Redmine plugin that allows running one Redmine installation with multiple hostnames, each with its own branding, email sender, and SMTP settings.

This is a fork of [florianeck/redmine_multi_hosts](https://github.com/florianeck/redmine_multi_hosts) with compatibility fixes for Redmine 4.x / Rails 5.x and new features.

## What's new in this fork

- **Rails 5.x / Redmine 4.x compatibility** — fixed deprecated `before_filter`, `after_filter`, `update_attributes` and migration syntax
- **Per-host SMTP settings** — each host can use its own SMTP server, credentials and sender address
- **Per-project organization binding** — pin a project to a specific host so its notifications always go out through that organization, no matter which domain the user is logged in through
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

After installation, go to **Administration → MultiHost** and:

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

## Per-project organization binding

By default, a notification email goes out through the host the triggering user is currently logged in with — this is the original behaviour of the plugin. If your Redmine serves several organizations and the same user (or admin) may sometimes log in through one domain while working on a project that belongs to another, this can result in notifications being sent from the wrong organization.

To prevent that, open a project's settings and set its **Organization (MultiHost)** field to the host that owns the project. From then on, every notification for that project (issues, news, documents, messages, wiki pages) will always use that host's branding, sender address and SMTP settings, regardless of which domain the user who triggered the notification was logged in through.

Leave the field empty (**none**) to keep the original login-domain-based behaviour for that project.

The default host is also selectable here, so you can explicitly pin a project to it as well, instead of relying on the login domain.

## How it works

For every outgoing email, the plugin determines which host's settings to apply, in this order:

1. **Project binding** — if the project the notification belongs to (read from the `X-Redmine-Project` header that core Redmine adds to its emails) has an explicit `Organization (MultiHost)` set, that host is used.
2. **Login domain** — otherwise, the host matching the domain the triggering user is currently logged in through is used.
3. **Recipient's host** — as a fallback, the host of a non-default-host recipient, if any.

Once a host is selected, the plugin:
- Overrides the page header title and browser tab title
- Uses that host's SMTP settings for delivery
- Replaces the sender address and app title in the email subject and body

## Original plugin

This plugin is based on [redmine_multi_hosts](https://github.com/florianeck/redmine_multi_hosts) by Florian Eck for akquinet.
