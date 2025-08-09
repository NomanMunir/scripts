# 🔐 Headscale Docker Setup

A production-ready **Headscale** deployment using Docker Compose with PostgreSQL database and comprehensive management tools.

**Headscale** is an open-source, self-hosted implementation of the Tailscale control server. It provides a secure mesh VPN solution for connecting your devices across different networks.

---

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐
│   Headscale     │    │   PostgreSQL    │
│   Control       │    │   Database      │
│   Server        │◄───┤                 │
│   Port: 8080    │    │   Port: 5432    │
│   Metrics: 9090 │    │                 │
└─────────────────┘    └─────────────────┘
```

## 📁 Directory Structure

```
headscale/
├── docker-compose.yml    # Docker services configuration
├── Makefile             # Management commands and automation
├── config/
│   └── config.yaml      # Headscale server configuration
├── data/               # Headscale runtime data (created on first run)
├── pgdata/            # PostgreSQL data (created on first run)
└── backups/           # Backup storage (created when needed)
```

---

## 🚀 Quick Start

### Prerequisites

- Docker & Docker Compose installed
- Make utility (for easier management)
- Open ports 8080 and 9090 on your server

### 1. Complete Setup (Recommended)

```bash
# Clone or navigate to the headscale directory
cd headscale/

# Run complete setup with default admin user
make quick-setup
```

### 2. Manual Step-by-Step Setup

```bash
# Start services
make up

# Create your first user
make create-user USER=admin

# Generate a pre-auth key
make preauthkey USERID=1

# Check status
make status
```

---

## 💻 Client Connection

### Connect a Device to Your Headscale Network

1. **Install Tailscale** on your device:

   - Linux: `curl -fsSL https://tailscale.com/install.sh | sh`
   - Windows/Mac: Download from [tailscale.com](https://tailscale.com/download)

2. **Get connection details:**

   ```bash
   make connect-help
   ```

3. **Connect your device:**

   ```bash
   # Replace YOUR_SERVER_IP and YOUR_AUTH_KEY with actual values
   tailscale up --login-server http://YOUR_SERVER_IP:8080 --authkey YOUR_AUTH_KEY
   ```

4. **Verify connection:**
   ```bash
   make list-nodes
   ```

---

## 🛠️ Management Commands

### Service Management

```bash
make up              # Start all services
make down            # Stop all services
make restart         # Restart services
make status          # Check service status
make update          # Update to latest images
```

### User Management

```bash
make list-users                    # List all users
make create-user USER=john         # Create new user
make delete-user USER=john         # Delete user and their nodes
```

### Pre-Authentication Keys

```bash
make preauthkey USERID=1           # Generate 24h reusable key
make list-preauthkeys USERID=1     # List keys for user
```

### Node Management

```bash
make list-nodes                    # List all connected devices
make node-info NODE=1              # Show detailed node info
make delete-node NODE=1            # Remove a device
```

### Monitoring & Logs

```bash
make logs                          # Show recent logs
make logs-follow                   # Follow logs in real-time
make logs-headscale               # Headscale service logs only
make health                       # Check service health
```

### Backup & Restore

```bash
make backup                                              # Create timestamped backup
make restore BACKUP=backups/headscale_backup_xxx.tar.gz # Restore from backup
```

### Advanced Operations

```bash
make shell                         # Open shell in container
make clean                         # Complete cleanup (DESTRUCTIVE!)
make config-validate              # Validate configuration
make help                         # Show all available commands
```

---

## ⚙️ Configuration

### Database Configuration

- **Type:** PostgreSQL 15
- **Database:** headscale
- **User:** headscale
- **Host:** postgres (internal Docker network)

### Network Configuration

- **IPv4 Range:** 100.64.0.0/10
- **IPv6 Range:** fd7a:115c:a1e0::/48
- **Magic DNS:** Enabled
- **Base Domain:** example.com

### Ports

- **8080:** Headscale control server
- **9090:** Metrics endpoint
- **50443:** gRPC API (internal)

### Key Features Enabled

- ✅ Magic DNS for easy device access
- ✅ Ephemeral nodes support (30m timeout)
- ✅ Prometheus metrics on port 9090
- ✅ Health check endpoints
- ✅ Comprehensive logging

---

## 📊 Monitoring

### Health Checks

```bash
# Manual health check
curl http://localhost:8080/health

# Comprehensive health status
make health
```

### Metrics

- **Prometheus metrics:** `http://localhost:9090/metrics`
- **Service status:** `make status`
- **Real-time logs:** `make logs-follow`

---

## 🔒 Security Considerations

### Default Security Features

- Database with dedicated user credentials
- Internal Docker networking
- Noise protocol for secure communication
- SSL/TLS ready configuration

### Recommended Security Enhancements

1. **Change default database password** in `docker-compose.yml`
2. **Use HTTPS** by configuring SSL certificates
3. **Firewall rules** to restrict access to ports 8080/9090
4. **Regular backups** using `make backup`
5. **Monitor logs** for suspicious activity

---

## 🔧 Troubleshooting

### Common Issues

#### Services won't start

```bash
# Check service status
make status

# View detailed logs
make logs

# Validate configuration
make config-validate
```

#### Can't connect clients

```bash
# Verify Headscale is running
make health

# Check user and pre-auth keys
make list-users
make list-preauthkeys USERID=1

# Review network configuration
make network-info
```

#### Database connection issues

```bash
# Check database logs
make logs-db

# Restart services
make restart
```

### Log Locations

- **Container logs:** `make logs`
- **Headscale config:** `config/config.yaml`
- **Data directory:** `./data/`
- **Backups:** `./backups/`

---

## 📚 Additional Resources

- **Headscale Documentation:** [headscale.net](https://headscale.net/)
- **Tailscale Client Docs:** [tailscale.com/kb](https://tailscale.com/kb/)
- **Docker Compose Reference:** [docs.docker.com](https://docs.docker.com/compose/)

---

## 🤝 Support

For help with this setup:

1. Check the troubleshooting section above
2. Review logs: `make logs-follow`
3. Validate configuration: `make config-validate`
4. Use `make help` for all available commands

---

## 📝 License

This configuration is provided as-is for educational and production use. Please refer to the official Headscale project for licensing information.

---

**🎉 Happy networking with Headscale!** 🚀
