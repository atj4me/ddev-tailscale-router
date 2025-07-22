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

- **`install.yaml`**  
  The DDEV add-on installation manifest. It copies the necessary files into your project's `.ddev` directory.
- **`docker-compose.tailscale-router.yaml`**  
  The core Docker Compose configuration that defines the `tailscale-router` service. It handles authenticating with Tailscale and uses `socat` to forward traffic from the Tailscale network to the DDEV web container.
- **`tailscale-router/config/`**
  This directory is copied into your project's `.ddev/tailscale-router/` directory. It contains the JSON configuration files for Tailscale's `serve` command, controlling whether the share is private or public. The Tailscale state is managed in a dedicated Docker volume, which is automatically cleaned up when the project is deleted.
- **`tests/test.bats`**  
  A test script to verify that the Tailscale integration is working correctly.
- **`README_DEBUG.md`**
  Provides detailed instructions on how to debug the GitHub Actions test suite using `tmate`.
- **GitHub Actions (`.github/workflows/tests.yml`)**  
  Automates testing to ensure functionality on every push and on a schedule.
- **Issue and PR Templates (`.github/`)**
  Templates for filing bug reports, feature requests, and submitting pull requests to streamline contributions.

## Getting Started

> [!WARNING]
> This add-on is only supported on Linux and Windows (WSL2). It is not compatible with macOS or systems with an `arm64` architecture (like Apple Silicon).

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

After installation, a `.ddev/.env.tailscale-router` file is created in your project. You need to add your Tailscale auth key to this file.

Obtain an auth key (e.g., an ephemeral, reusable key) and set it using the `ddev dotenv` command:

```bash
ddev dotenv set .ddev/.env.tailscale-router --ts-authkey=tskey-auth-xxxx
```

Then restart DDEV:

```bash
ddev restart
```

### 4. Configure Share Privacy (Optional) 
By default, this add-on creates a private share, accessible only by you. You can change this to a public share (accessible to anyone in your Tailnet) by setting the TS_PRIVACY environment variable. 

* To enable public sharing: 

  ```bash
  ddev dotenv set .ddev/.env.tailscale-router --ts-privacy=public
  ```

* To switch back to private sharing (the default): 

  ```bash
  ddev dotenv set .ddev/.env.tailscale-router --ts-privacy=private
  ```

Remember to ddev restart after changing this setting for it to take effect. 

### 5. Access Your DDEV Sites Securely

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

This project is licensed under the Apache License 2.0. See the [LICENSE](LICENSE) file for details.

---

Maintained by `@atj4me` 🚀  

Let me know if you want any tweaks! 🎯