# DDEV Tailscale Router v3.0.0 Release Notes

## 🚀 Major Release - YAML Configuration Migration and Enhanced Features

This major release introduces significant architectural improvements and breaking changes that modernize the DDEV Tailscale Router add-on.

### 🔧 BREAKING CHANGES

- **Migrated from JSON to YAML-based configuration** for better maintainability and clarity
- **Updated Tailscale proxy settings and command structure** with improved reliability
- **Improved add-on installation and configuration process** with automatic cleanup of old files
- Users will need to remove old configuration files and may require reconfiguration of existing setups

### ✨ NEW FEATURES

- **Enhanced DDEV Tailscale commands** with better error handling and user feedback
- **Improved authentication flow** with TS_AUTHKEY environment variable support
- **Better proxy/funnel status management** with automatic reset capabilities to avoid conflicts
- **New command structure** with clearer help documentation and examples
- **Interactive login support** as an alternative to auth keys
- **Enhanced URL management** with `ddev tailscale url` and `ddev tailscale launch` commands

### 🛠️ IMPROVEMENTS

- **Complete rewrite of the command infrastructure** for better reliability and maintainability
- **Added comprehensive GitHub issue templates and workflows** for better project management
- **Enhanced testing framework** with better coverage and multi-platform support
- **Improved documentation and user experience** with clearer setup instructions
- **Better error messages and troubleshooting guidance** for common issues
- **Updated installation process** with helpful post-install instructions

### 🔧 TECHNICAL CHANGES

- **Migrated to userspace networking** for better macOS compatibility
- **Updated Docker configurations** for improved reliability and security
- **Enhanced pre/post installation actions** with automatic cleanup
- **Better cleanup and state management** with proper logout handling
- **Improved testing infrastructure** with BATS testing framework
- **Added proper GitHub Actions workflow** for automated testing

### 📋 Migration Instructions

If you're upgrading from a previous version:

1. **Remove the old add-on** (if installed):
   ```bash
   ddev add-on remove tailscale-router
   ```

2. **Install the new version**:
   ```bash
   ddev add-on get atj4me/ddev-tailscale-router
   ```

3. **Set up your Tailscale auth key**:
   ```bash
   echo 'export TS_AUTHKEY=tskey-auth-your-key-here' >> ~/.bashrc
   source ~/.bashrc
   ```

4. **Restart DDEV**:
   ```bash
   ddev restart
   ```

5. **Start sharing**:
   ```bash
   ddev tailscale launch
   ```

### 🆘 Support

For help with migration or issues:
- Check the updated [README.md](README.md) for comprehensive setup instructions
- Review the troubleshooting section for common issues
- File an issue using our new issue templates

### 🔗 Full Changelog

For detailed technical changes, see Pull Request: https://github.com/atj4me/ddev-tailscale-router/pull/21

---

**Maintained by [@atj4me](https://github.com/atj4me) 🚀**