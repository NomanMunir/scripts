
# RustDesk Server Makefile
# Usage: make <target>
# Run 'make help' to see available commands.

COMPOSE ?= docker-compose

.PHONY: help up down restart logs ps pull update key firewall-ufw status backup clean install-docker
help:
	@echo "RustDesk Server Management Makefile"
	@echo "Usage: make <target>"
	@echo "Available targets:"
	@echo "  help           Show this help message"
	@echo "  install-docker Install Docker via convenience script (Ubuntu/Debian)"
	@echo "  up             Start RustDesk server stack (detached)"
	@echo "  down           Stop RustDesk server stack"
	@echo "  restart        Restart RustDesk server containers"
	@echo "  logs           Show and follow logs (last 200 lines)"
	@echo "  ps             Show container status"
	@echo "  pull           Pull latest images"
	@echo "  update         Pull and restart stack"
	@echo "  key            Show public key for RustDesk client"
	@echo "  firewall-ufw   Open required ports in UFW firewall"
	@echo "  status         Show listening ports and container status"
	@echo "  backup         Backup ./data directory"
	@echo "  clean          Remove containers and volumes (DANGEROUS)"

install-docker:
	@echo "[INFO] Installing Docker via convenience script (Ubuntu/Debian)..."
	curl -fsSL https://get.docker.com | sh
	sudo usermod -aG docker \$$USER || true
	@echo "[INFO] Re-login for group changes to take effect."

up:
	@echo "[INFO] Starting RustDesk server stack..."
	$(COMPOSE) up -d
	@echo "[INFO] Stack started. Use 'make logs' to view logs."

down:
	@echo "[INFO] Stopping RustDesk server stack..."
	$(COMPOSE) down
	@echo "[INFO] Stack stopped."

restart:
	@echo "[INFO] Restarting RustDesk server containers..."
	$(COMPOSE) restart
	@echo "[INFO] Containers restarted."

logs:
	@echo "[INFO] Showing last 200 log lines. Press Ctrl+C to exit."
	$(COMPOSE) logs -f --tail=200

ps:
	@echo "[INFO] Showing container status:"
	$(COMPOSE) ps

pull:
	@echo "[INFO] Pulling latest images..."
	$(COMPOSE) pull
	@echo "[INFO] Images updated."

update: pull up

key:
	@if [ -f ./data/id_ed25519.pub ]; then \
	  echo "[INFO] Public key (paste into RustDesk client 'Key'):"; \
	  echo "------------------------------------------------"; \
	  cat ./data/id_ed25519.pub; \
	else \
	  echo "[WARN] No key yet. Start the stack once (make up) to generate id_ed25519.pub, then re-run 'make key'."; \
	fi

# Open firewall (UFW). Comment out 21118/21119 if you don't use the web client.
firewall-ufw:
	@echo "[INFO] Opening required ports in UFW firewall..."
	sudo ufw allow 21115/tcp
	sudo ufw allow 21116/tcp
	sudo ufw allow 21116/udp
	sudo ufw allow 21117/tcp
	sudo ufw allow 21118/tcp
	sudo ufw allow 21119/tcp
	@echo "[INFO] UFW rules updated."

status:
	@echo "[INFO] Listening sockets:"
	@ss -ltnup | grep -E ':(21115|21116|21117|21118|21119)' || true
	@echo "[INFO] Containers:"
	@$(COMPOSE) ps

backup:
	@echo "[INFO] Backing up ./data directory..."
	tar -czf rustdesk-backup-\$$(date +%F).tgz data
	@echo "[INFO] Backup created: rustdesk-backup-\$$(date +%F).tgz"

clean:
	@echo "[WARN] Removing containers and volumes. THIS WILL DELETE ALL DATA!"
	$(COMPOSE) down -v
	@echo "[INFO] Clean complete."
