[![add-on registry](https://img.shields.io/badge/DDEV-Add--on_Registry-blue)](https://addons.ddev.com)
[![tests](https://github.com/atj4me/ddev-tailscale-router/actions/workflows/tests.yml/badge.svg?branch=main)](https://github.com/atj4me/ddev-tailscale-router/actions/workflows/tests.yml?query=branch%3Amain)
[![last commit](https://img.shields.io/github/last-commit/atj4me/ddev-tailscale-router)](https://github.com/atj4me/ddev-tailscale-router/commits)
[![release](https://img.shields.io/github/v/release/atj4me/ddev-tailscale-router)](https://github.com/atj4me/ddev-tailscale-router/releases/latest)

# ddev-tailscale-router <!-- omit in toc -->

- [What is ddev-tailscale-router?](#what-is-ddev-tailscale-router)
- [Use Cases](#use-cases)
- [Prerequisites](#prerequisites)
- [Components of the Repository](#components-of-the-repository)
- [Getting Started](#getting-started)
- [Commands](#commands)
- [Testing](#testing)
- [Contributing](#contributing)
- [License](#license)

## What is ddev-tailscale-router?

**ddev-tailscale-router** is a DDEV add-on that provides stable, secure URLs for your local DDEV development sites using [Tailscale](https://tailscale.com/). Unlike temporary sharing solutions, this gives you permanent, human-readable URLs that work across all your Tailscale-connected devices.

Read the full blog post: [Tailscale for DDEV: Simple and Secure Project Sharing](https://ddev.com/blog/tailscale-router-ddev-addon/)

## Use Cases

This add-on is particularly useful for:

- **Cross-device testing**: Test your sites on phones, tablets, or other devices without being on the same Wi-Fi network
- **Stable webhook URLs**: Use permanent Tailscale URLs as reliable endpoints for webhooks from payment gateways, APIs, etc.
- **Team collaboration**: Share your development environment with team members to show work in progress
- **Remote development**: Access your local development sites securely from anywhere

## Prerequisites

Before installing the add-on:

1. **Install Tailscale** on your development machine: [Download Tailscale](https://tailscale.com/download)
2. **Add a second device** to your Tailscale network (phone, tablet, or another computer)
3. **Enable HTTPS** in your [Tailscale admin console](https://login.tailscale.com/admin/dns) by clicking "Enable HTTPS..." (required for TLS certificate generation)

## Components of the Repository

- **`install.yaml`** - DDEV add-on installation manifest that copies necessary files and shows setup instructions
- **`docker-compose.tailscale-router.yaml`** - Core Docker Compose configuration defining the `tailscale-router` service with Tailscale authentication and `socat` traffic forwarding
- **`commands/tailscale-router/tailscale`** - Custom DDEV command providing access to Tailscale CLI with helpful shortcuts
- **`tailscale-router/config/`** - JSON configuration files for Tailscale's serve command:
  - `tailscale-private.json` - Private sharing configuration (default)
  - `tailscale-public.json` - Public sharing configuration
- **`tests/test.bats`** - Automated test script for verifying Tailscale integration
- **`.github/workflows/tests.yml`** - GitHub Actions for automated testing on push and schedule
- **`.github/ISSUE_TEMPLATE/` and `PULL_REQUEST_TEMPLATE.md`** - Templates for streamlined contributions

## Getting Started

### 1. Install the Add-on

```bash
ddev add-on get atj4me/ddev-tailscale-router
```

### 2. Get a Tailscale Auth Key

Get an auth key from the [Tailscale admin console](https://login.tailscale.com/admin/settings/keys) (ephemeral, reusable keys are recommended).

### 3. Configure the Auth Key

```bash
ddev dotenv set .ddev/.env.tailscale-router --ts-authkey=tskey-auth-your-key-here
```

### 4. Restart DDEV

```bash
ddev restart
```

### 5. Access Your Site

After restarting, you can access your site in several ways:

- **Launch in browser**: `ddev tailscale launch`
- **Get the URL**: `ddev tailscale url` 
- **Find in admin console**: [Tailscale admin console](https://login.tailscale.com/admin/machines)

Your project's permanent Tailscale URL will look like: `https://<project-name>.<your-tailnet>.ts.net`

### 6. Configure Privacy (Optional)

By default, your project is only accessible to devices on your Tailscale network (private mode). You can make it publicly accessible:

```bash
# Switch to public mode (accessible to anyone on the internet)
ddev dotenv set .ddev/.env.tailscale-router --ts-privacy=public
ddev restart

# Switch back to private mode (default)
ddev dotenv set .ddev/.env.tailscale-router --ts-privacy=private
ddev restart
```

## Commands

The add-on provides two types of commands:

### Container Commands

Access all [Tailscale CLI](https://tailscale.com/kb/1080/cli) commands plus helpful shortcuts:

```bash
# Standard Tailscale commands
ddev tailscale status
ddev tailscale ping <device>

# Helpful shortcuts
ddev tailscale stat      # Show status with self and active peers only
ddev tailscale proxy     # Show funnel status
ddev tailscale url       # Get your project's Tailscale URL
```

### Host Commands

Launch your Tailscale URL directly in your browser:

```bash
ddev tailscale launch    # Launch your project's Tailscale URL in browser
``` 

## Testing

This add-on includes automated tests to ensure that the Tailscale router works correctly inside a DDEV environment.

To run tests locally:

```bash
bats tests/test.bats
```

Tests also run automatically in GitHub Actions on every push.

## Contributing

Contributions are welcome! If you have suggestions, bug reports, or feature requests, please:

1. Fork the repository.
2. Create a new branch.
3. Make your changes.
4. Submit a pull request.

## License

This project is licensed under the Apache License 2.0. See the [LICENSE](LICENSE) file for details.

---

Maintained by `@atj4me` 🚀  

Let me know if you want any tweaks! 🎯
