[![tests](https://github.com/atj4me/ddev-tailscale-router/actions/workflows/tests.yml/badge.svg)](https://github.com/atj4me/ddev-tailscale-router/actions/workflows/tests.yml) ![project is maintained](https://img.shields.io/maintenance/yes/2025.svg)

# ddev-tailscale-router <!-- omit in toc -->

- [What is ddev-tailscale-router?](#what-is-ddev-tailscale-router)
- [Components of the Repository](#components-of-the-repository)
- [Getting Started](#getting-started)
- [Testing](#testing)
- [Contributing](#contributing)
- [License](#license)

## What is ddev-tailscale-router?

**ddev-tailscale-router** is a DDEV add-on that enables a **Tailscale subnet router** inside a DDEV-managed environment. This allows you to access your local DDEV development sites securely over Tailscale from anywhere without exposing them publicly.

With this setup, your development sites become accessible over Tailscale's secure, peer-to-peer VPN, making it ideal for remote development, testing, and collaboration.

## Components of the Repository

- **`docker-compose.tailscale-router.yaml`**  
  The core configuration file that sets up the Tailscale subnet router within the DDEV environment.
- **`install.yaml`**  
  Provides instructions for setting up and installing the add-on in a DDEV project.
- **`tests/test.bats`**  
  A test script to verify that the Tailscale integration is working correctly.
- **GitHub Actions (`.github/workflows/tests.yml`)**  
  Automates testing to ensure functionality on every push.

## Getting Started

### 1. Install DDEV and Tailscale

Ensure you have:
- [DDEV](https://ddev.readthedocs.io/en/stable/) installed
- [Docker](https://www.docker.com/get-started) installed and running
- A [Tailscale](https://tailscale.com/) account and auth key

### 2. Add ddev-tailscale-router to Your Project

```bash
ddev add-on get atj4me/ddev-tailscale-router
ddev restart
```

### 3. Authenticate with Tailscale

Obtain an [auth key](https://tailscale.com/kb/1085/auth-keys/) and set it in your environment:

```bash
ddev config global --env-add TAILSCALE_AUTHKEY=your_auth_key
```

Then restart DDEV:

```bash
ddev restart
```

### 4. Access Your DDEV Sites Securely

Once connected to Tailscale, use the **Tailscale-assigned IP** of your DDEV environment to access your local development sites securely from any connected device.

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

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

Maintained by `@atj4me` 🚀  

Let me know if you want any tweaks! 🎯