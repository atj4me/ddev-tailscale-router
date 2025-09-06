[![add-on registry](https://img.shields.io/badge/DDEV-Add--on_Registry-blue)](https://addons.ddev.com)
[![tests](https://github.com/atj4me/ddev-tailscale-router/actions/workflows/tests.yml/badge.svg?branch=main)](https://github.com/atj4me/ddev-tailscale-router/actions/workflows/tests.yml?query=branch%3Amain)
[![last commit](https://img.shields.io/github/last-commit/atj4me/ddev-tailscale-router)](https://github.com/atj4me/ddev-tailscale-router/commits)
[![release](https://img.shields.io/github/v/release/atj4me/ddev-tailscale-router)](https://github.com/atj4me/ddev-tailscale-router/releases/latest)

# DDEV Tailscale Router <!-- omit in toc -->

- [Overview](#overview)
- [Use Cases](#use-cases)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Advanced Customization](#advanced-customization)
- [Components of the Repository](#components-of-the-repository)
- [Testing](#testing)
- [Contributing](#contributing)
- [License](#license)

## Overview

[Tailscale](https://tailscale.com/) is a VPN service that creates a private and secure network between your devices.

This add-on integrates Tailscale into your [DDEV](https://ddev.com) project. Unlike temporary sharing solutions, this gives you permanent, human-readable URLs that work across all your Tailscale-connected devices.

Read the full blog post: [Tailscale for DDEV: Simple and Secure Project Sharing](https://ddev.com/blog/tailscale-router-ddev-addon/)

## Use Cases

This add-on is particularly useful for:

- **Cross-device testing**: Test your sites on phones, tablets, or other devices without being on the same Wi-Fi network
- **Stable webhook URLs**: Use permanent Tailscale URLs as reliable endpoints for webhooks from payment gateways, APIs, etc.
- **Team collaboration**: Share your development environment with team members to show work in progress
- **Remote development**: Access your local development sites securely from anywhere

## Prerequisites

Before installing the add-on:

1. [Install Tailscale](https://tailscale.com/download) on any two devices (computer, phone, or tablet). This is required to generate the auth key.
2. [Generate an auth key](https://tailscale.com/kb/1085/auth-keys) in your [Keys settings](https://login.tailscale.com/admin/settings/keys) (ephemeral, reusable keys are recommended).
3. [Enable HTTPS](https://tailscale.com/kb/1153/enabling-https) in your [DNS settings](https://login.tailscale.com/admin/dns) by clicking "Enable HTTPS..." (required for TLS certificate generation).

## Installation

```bash
# get the auth key from prerequisites
ddev dotenv set .ddev/.env.tailscale-router --ts-authkey=tskey-auth-your-key-here

ddev add-on get atj4me/ddev-tailscale-router
ddev restart

# Launch your project's Tailscale URL in browser
ddev tailscale launch
# Or get your project's Tailscale URL
ddev tailscale url
```

Your project's permanent Tailscale URL will look like: `https://<project-name>.<your-tailnet>.ts.net`. Also, it can be found in your [Tailscale admin console](https://login.tailscale.com/admin/machines).

### Configure Privacy (Optional)

By default, your project is only accessible to devices on your Tailscale network (private mode). You can make it publicly accessible:

```bash
# Switch to public mode (accessible to anyone on the internet)
ddev dotenv set .ddev/.env.tailscale-router --ts-privacy=public
ddev restart

# Switch back to private mode (default)
ddev dotenv set .ddev/.env.tailscale-router --ts-privacy=private
ddev restart
```

## Usage

Access all [Tailscale CLI](https://tailscale.com/kb/1080/cli) commands plus helpful shortcuts:

| Command | Description |
| ------- | ----------- |
| `ddev tailscale launch` | Launch your project's Tailscale URL in browser |
| `ddev tailscale <anything>` | Run any Tailscale CLI command |
| `ddev tailscale status` | Show Tailscale status |
| `ddev tailscale ping <device>` | Ping a Tailscale device |
| `ddev tailscale stat` | Show status with self and active peers only |
| `ddev tailscale proxy` | Show funnel status |
| `ddev tailscale url` | Get your project's Tailscale URL |

## Advanced Customization

All customization options (use with caution):

| Variable | Flag | Default |
| -------- | ---- | ------- |
| `TS_DOCKER_IMAGE` | `--ts-docker-image` | `tailscale/tailscale:latest` |
| `TS_AUTHKEY` | `--ts-authkey` | (none, required) |
| `TS_PRIVACY` | `--ts-privacy` | `private` (`private`/`public`) |

## Components of the Repository

- **`install.yaml`** - DDEV add-on installation manifest that copies necessary files and shows setup instructions
- **`docker-compose.tailscale-router.yaml`** - Core Docker Compose configuration defining the `tailscale-router` service with Tailscale authentication and `socat` traffic forwarding
- **`commands/host/tailscale`** - Custom DDEV host command providing access to Tailscale CLI with helpful shortcuts
- **`tailscale-router/config/`** - JSON configuration files for Tailscale's serve command:
  - `tailscale-private.json` - Private sharing configuration (default)
  - `tailscale-public.json` - Public sharing configuration
- **`tests/test.bats`** - Automated test script for verifying Tailscale integration
- **`.github/workflows/tests.yml`** - GitHub Actions for automated testing on push and schedule
- **`.github/ISSUE_TEMPLATE/` and `PULL_REQUEST_TEMPLATE.md`** - Templates for streamlined contributions

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

Maintained by [@atj4me](https://github.com/atj4me) 🚀

Let me know if you want any tweaks! 🎯
