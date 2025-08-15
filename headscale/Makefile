# =============================================================================
# Headscale Docker Management Makefile
# =============================================================================
# Author: GitHub Copilot
# Description: Simplifies common Headscale operations with organized sections

.PHONY: help up down restart status logs logs-follow clean backup restore shell exec users create-user list-users delete-user preauthkey routes health

# =============================================================================
# HELP & DOCUMENTATION
# =============================================================================

# Default target
help: ## Show this help message
	@echo "🎯 Headscale Docker Management Commands"
	@echo "========================================"
	@echo ""
	@echo "📚 QUICK START:"
	@echo "  make quick-setup           # Complete setup with default user"
	@echo "  make connect-help          # Show client connection guide"
	@echo ""
	@echo "🚀 SERVICE MANAGEMENT:"
	@echo "  up                         # Start all services"
	@echo "  down                       # Stop all services"
	@echo "  restart                    # Restart all services"
	@echo "  status                     # Show service status"
	@echo "  update                     # Pull latest images and restart"
	@echo ""
	@echo "👥 USER MANAGEMENT:"
	@echo "  list-users                 # List all users"
	@echo "  create-user USER=name      # Create a new user"
	@echo "  delete-user USER=name      # Delete a user"
	@echo ""
	@echo "🔑 PRE-AUTH KEYS:"
	@echo "  preauthkey USERID=1        # Generate a pre-auth key"
	@echo "  list-preauthkeys USERID=1  # List pre-auth keys for a user"
	@echo ""
	@echo "💻 NODE MANAGEMENT:"
	@echo "  list-nodes                 # List all nodes"
	@echo "  node-info NODE=id          # Show detailed node info"
	@echo "  delete-node NODE=id        # Delete a node"
	@echo ""
	@echo "📋 MONITORING & LOGS:"
	@echo "  logs                       # Show recent logs"
	@echo "  logs-follow                # Follow logs in real-time"
	@echo "  logs-headscale             # Show headscale logs only"
	@echo "  health                     # Check service health"
	@echo ""
	@echo "🛠️  MAINTENANCE:"
	@echo "  backup                     # Create backup"
	@echo "  shell                      # Open shell in container"
	@echo "  clean                      # Remove all data (DESTRUCTIVE!)"
	@echo ""
	@echo "💡 EXAMPLES:"
	@echo "  make create-user USER=john"
	@echo "  make preauthkey USERID=1"
	@echo "  make backup"
	@echo "  make logs-follow"

connect-help: ## Show detailed client connection instructions
	@echo "📱 Client Connection Guide"
	@echo "=========================="
	@echo ""
	@echo "1️⃣  Create a user (if not done already):"
	@echo "   make create-user USER=myuser"
	@echo ""
	@echo "2️⃣  Generate a pre-auth key:"
	@echo "   make preauthkey USERID=1"
	@echo ""
	@echo "3️⃣  On your client device, install Tailscale and run:"
	@echo "   tailscale up --login-server http://$(shell hostname -I | awk '{print $$1}'):8080 --authkey YOUR_KEY"
	@echo ""
	@echo "4️⃣  Verify connection:"
	@echo "   make list-nodes"
	@echo ""
	@echo "📍 Your Headscale server is accessible at:"
	@echo "   http://$(shell hostname -I | awk '{print $$1}'):8080"

# =============================================================================
# SERVICE MANAGEMENT
# =============================================================================

up: ## Start all services
	@echo "🚀 Starting Headscale services..."
	docker-compose up -d
	@echo "✅ Services started. Use 'make status' to check."

down: ## Stop all services
	@echo "🛑 Stopping Headscale services..."
	docker-compose down
	@echo "✅ Services stopped."

restart: ## Restart all services
	@echo "🔄 Restarting Headscale services..."
	docker-compose restart
	@echo "✅ Services restarted."

status: ## Show service status
	@echo "📊 Service Status"
	@echo "================="
	@docker-compose ps

update: ## Pull latest images and restart
	@echo "🔄 Updating Headscale..."
	@docker-compose pull
	@make restart
	@echo "✅ Update completed!"

quick-setup: ## Complete setup with default admin user
	@echo "🚀 Quick Headscale Setup"
	@echo "========================"
	@make up
	@echo "⏳ Waiting for services to be ready..."
	@sleep 10
	@make create-user USER=admin
	@echo ""
	@echo "🎉 Setup complete!"
	@echo "Next steps:"
	@echo "1. Generate a pre-auth key: make preauthkey USERID=1"
	@echo "2. Connect your devices using the generated key"

# =============================================================================
# USER MANAGEMENT
# =============================================================================

users: list-users ## Alias for list-users

list-users: ## List all users
	@echo "👥 Headscale Users"
	@echo "=================="
	@docker exec -it headscale headscale users list || echo "❌ Failed to list users. Is Headscale running?"

create-user: ## Create a new user (usage: make create-user USER=username)
	@if [ -z "$(USER)" ]; then \
		echo "❌ Error: USER parameter is required"; \
		echo "Usage: make create-user USER=username"; \
		exit 1; \
	fi
	@echo "👤 Creating user: $(USER)"
	@docker exec -it headscale headscale users create $(USER)
	@echo "✅ User '$(USER)' created successfully!"
	@echo ""
	@echo "📱 Next Steps:"
	@echo "=============="
	@echo "1️⃣  Generate a pre-auth key for this user:"
	@echo "   make preauthkey USERID=1"
	@echo ""
	@echo "2️⃣  On your client device, install Tailscale and run:"
	@echo "   sudo tailscale up --login-server http://maximum-logically-sunbird.ngrok-free.app --authkey YOUR_AUTHKEY"
	@echo ""
	@echo "   📝 Replace YOUR_AUTHKEY with the key generated in step 1"
	@echo "   📝 Keep the --login-server URL exactly as shown above"
	@echo ""
	@echo "3️⃣  Verify the connection:"
	@echo "   make list-nodes"
	@echo ""

delete-user: ## Delete a user (usage: make delete-user USER=username)
	@if [ -z "$(USER)" ]; then \
		echo "❌ Error: USER parameter is required"; \
		echo "Usage: make delete-user USER=username"; \
		exit 1; \
	fi
	@echo "🗑️  Deleting user: $(USER)"
	@echo "⚠️  This will also delete all nodes for this user!"
	@read -p "Are you sure? (y/N): " confirm && [ "$$confirm" = "y" ] || exit 1
	@docker exec -it headscale headscale users destroy --name $(USER) --force
	@echo "✅ User '$(USER)' deleted!"

# =============================================================================
# PRE-AUTHENTICATION KEYS
# =============================================================================

preauthkey: ## Generate a pre-auth key (usage: make preauthkey [USERID=1])
	@echo "🔑 Generate Pre-authentication Key"
	@echo "=================================="
	@if [ -z "$(USERID)" ]; then \
		echo "👥 Available Users:"; \
		docker exec -it headscale headscale users list; \
		echo ""; \
		echo "Usage: make preauthkey USERID=1"; \
		echo ""; \
	else \
		echo "🔑 Generating 24h reusable pre-auth key for User ID: $(USERID)"; \
		docker exec -it headscale headscale preauthkeys create --user $(USERID) --expiration 24h --reusable; \
		echo ""; \
		echo "📱 Connection Instructions:"; \
		echo "==========================="; \
		echo "Copy the authkey from above and run this command on your client device:"; \
		echo ""; \
		echo "   sudo tailscale up --login-server http://maximum-logically-sunbird.ngrok-free.app --authkey YOUR_AUTHKEY"; \
		echo ""; \
		echo "   📝 Replace YOUR_AUTHKEY with the key generated above"; \
		echo "   📝 Keep the --login-server URL exactly as shown"; \
		echo ""; \
		echo "✅ After connecting, verify with: make list-nodes"; \
		echo ""; \
	fi

list-preauthkeys: ## List pre-auth keys for a user (usage: make list-preauthkeys USERID=1)
	@echo "🔑 Pre-authentication Keys"
	@echo "=========================="
	@if [ -z "$(USERID)" ]; then \
		echo "❌ Error: USERID parameter is required"; \
		echo ""; \
		echo "Usage: make list-preauthkeys USERID=1"; \
		exit 1; \
	else \
		echo "📋 Listing pre-auth keys for User ID: $(USERID)"; \
		docker exec -it headscale headscale preauthkeys list --user $(USERID); \
	fi

# =============================================================================
# NODE MANAGEMENT
# =============================================================================

nodes: list-nodes ## Alias for list-nodes

list-nodes: ## List all nodes
	@echo "💻 Headscale Nodes"
	@echo "=================="
	@docker exec -it headscale headscale nodes list

node-info: ## Show detailed info for a node (usage: make node-info NODE=node_id)
	@if [ -z "$(NODE)" ]; then \
		echo "❌ Error: NODE parameter is required"; \
		echo "Usage: make node-info NODE=node_id"; \
		exit 1; \
	fi
	@echo "💻 Node Information for ID: $(NODE)"
	@echo "===================================="
	@docker exec -it headscale headscale nodes get $(NODE)

delete-node: ## Delete a node (usage: make delete-node NODE=node_id)
	@if [ -z "$(NODE)" ]; then \
		echo "❌ Error: NODE parameter is required"; \
		echo "Usage: make delete-node NODE=node_id"; \
		exit 1; \
	fi
	@echo "🗑️  Deleting node: $(NODE)"
	@docker exec -it headscale headscale nodes delete --identifier $(NODE) --force

# =============================================================================
# ROUTES MANAGEMENT
# =============================================================================

routes: list-routes ## Alias for list-routes

list-routes: ## List all routes
	@echo "🛣️  Routes"
	@echo "=========="
	@docker exec -it headscale headscale routes list

# =============================================================================
# MONITORING & LOGGING
# =============================================================================

logs: ## Show recent logs from all services
	@echo "📋 Recent Logs"
	@echo "=============="
	docker-compose logs --tail=50

logs-follow: ## Follow logs in real-time
	@echo "📋 Following logs (Ctrl+C to stop)"
	@echo "=================================="
	docker-compose logs -f

logs-headscale: ## Show logs from headscale service only
	@echo "📋 Headscale Logs"
	@echo "================="
	docker-compose logs --tail=50 headscale

logs-db: ## Show logs from database service only
	@echo "📋 Database Logs"
	@echo "================"
	docker-compose logs --tail=50 postgres

dev-logs: ## Show detailed logs with debug info
	@echo "🐛 Debug Logs"
	@echo "============="
	docker-compose logs -f --tail=100

health: ## Check service health and connectivity
	@echo "🏥 Health Check"
	@echo "==============="
	@echo "🔍 Checking Headscale API..."
	@curl -s -o /dev/null -w "   Status: %{http_code}\n" http://localhost:8080/health 2>/dev/null || echo "   Status: Not responding"
	@echo "📊 Checking Metrics endpoint..."
	@curl -s -o /dev/null -w "   Status: %{http_code}\n" http://localhost:9090/metrics 2>/dev/null || echo "   Status: Not responding"
	@echo ""
	@make status

# =============================================================================
# MAINTENANCE & ADMINISTRATION
# =============================================================================

shell: ## Open a shell in the headscale container
	@echo "🐚 Opening shell in Headscale container..."
	@docker exec -it headscale sh

exec: ## Execute a command in headscale container (usage: make exec CMD="command")
	@if [ -z "$(CMD)" ]; then \
		echo "❌ Error: CMD parameter is required"; \
		echo "Usage: make exec CMD=\"headscale users list\""; \
		exit 1; \
	fi
	@docker exec -it headscale $(CMD)

backup: ## Create a backup of configuration and data
	@echo "💾 Creating Backup"
	@echo "=================="
	@TIMESTAMP=$$(date +%Y%m%d_%H%M%S); \
	mkdir -p backups; \
	tar -czf backups/headscale_backup_$$TIMESTAMP.tar.gz config/ data/ pgdata/ docker-compose.yml Makefile; \
	echo "✅ Backup created: backups/headscale_backup_$$TIMESTAMP.tar.gz"

restore: ## Restore from backup (usage: make restore BACKUP=backup_file.tar.gz)
	@if [ -z "$(BACKUP)" ]; then \
		echo "❌ Error: BACKUP parameter is required"; \
		echo "Usage: make restore BACKUP=backups/headscale_backup_20240101_120000.tar.gz"; \
		exit 1; \
	fi
	@if [ ! -f "$(BACKUP)" ]; then \
		echo "❌ Error: Backup file $(BACKUP) not found"; \
		exit 1; \
	fi
	@echo "🔄 Restoring from backup: $(BACKUP)"
	@echo "⚠️  This will overwrite current configuration and data!"
	@read -p "Are you sure? (y/N): " confirm && [ "$$confirm" = "y" ] || exit 1
	@make down
	@tar -xzf $(BACKUP)
	@make up
	@echo "✅ Restore completed!"

clean: ## Remove all containers, volumes, and networks (DESTRUCTIVE!)
	@echo "🧹 Complete Cleanup"
	@echo "==================="
	@echo "⚠️  This will remove ALL Headscale data permanently!"
	@echo "📋 Make sure you have a backup!"
	@read -p "Type 'DELETE' to confirm: " confirm && [ "$$confirm" = "DELETE" ] || exit 1
	@docker-compose down -v --remove-orphans
	@docker network prune -f
	@sudo rm -rf data/ pgdata/
	@echo "✅ Cleanup completed!"

# =============================================================================
# CONFIGURATION & TROUBLESHOOTING
# =============================================================================

config-validate: ## Validate headscale configuration
	@echo "✅ Validating Configuration"
	@echo "==========================="
	@docker exec -it headscale headscale configtest || echo "❌ Configuration validation failed"

config-show: ## Show current configuration file
	@echo "⚙️  Current Configuration"
	@echo "========================="
	@cat config/config.yaml

network-info: ## Show docker network information
	@echo "🌐 Network Information"
	@echo "====================="
	@docker network ls | grep headscale
	@echo ""
	@docker network inspect headscale_headscale-net
