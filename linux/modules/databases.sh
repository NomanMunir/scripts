#!/bin/bash

#==============================================================================
# Database Systems Module
# SQL and NoSQL databases, database tools and clients
#==============================================================================

# Install PostgreSQL
install_postgresql() {
    if confirm_install "PostgreSQL Database" "Advanced open-source relational database"; then
        print_section "Installing PostgreSQL"
        
        local packages=(
            postgresql
            postgresql-contrib
            postgresql-client
            pgadmin4
            libpq-dev
            postgresql-server-dev-all
        )
        
        install_packages "${packages[@]}"
        
        enable_and_start_service postgresql
        
        print_info "Configuring PostgreSQL..."
        if [ -n "$CURRENT_USER" ]; then
            # Create a database user
            sudo -u postgres createuser --interactive "$CURRENT_USER" >> "$LOG_FILE" 2>&1 || true
            sudo -u postgres createdb "$CURRENT_USER" >> "$LOG_FILE" 2>&1 || true
            print_success "PostgreSQL user '$CURRENT_USER' created"
        fi
        
        print_success "PostgreSQL installed and configured"
        print_info "Default superuser: postgres"
        print_info "To set postgres password: sudo -u postgres psql -c \"\\password postgres\""
    fi
}

# Install MySQL/MariaDB
install_mysql() {
    if confirm_install "MariaDB Database" "Popular MySQL-compatible database server"; then
        print_section "Installing MariaDB"
        
        local packages=(
            mariadb-server
            mariadb-client
            libmysqlclient-dev
            mycli
            phpmyadmin
        )
        
        install_packages "${packages[@]}"
        
        enable_and_start_service mariadb
        
        print_success "MariaDB installed and started"
        print_warning "Run 'mysql_secure_installation' to secure your installation"
        print_info "Default root access: sudo mysql -u root"
    fi
}

# Install SQLite
install_sqlite() {
    if confirm_install "SQLite Database" "Lightweight file-based SQL database"; then
        print_section "Installing SQLite"
        
        local packages=(
            sqlite3
            libsqlite3-dev
            sqlitebrowser
            sqlite3-doc
        )
        
        install_packages "${packages[@]}"
        
        print_success "SQLite installed with browser GUI"
    fi
}

# Install MongoDB
install_mongodb() {
    if confirm_install "MongoDB Database" "Popular NoSQL document database"; then
        print_section "Installing MongoDB"
        
        # Add MongoDB repository
        print_info "Adding MongoDB repository..."
        curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | gpg --dearmor -o /usr/share/keyrings/mongodb-server-7.0.gpg
        echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu $(lsb_release -cs)/mongodb-org/7.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-7.0.list
        
        apt update >> "$LOG_FILE" 2>&1
        
        local packages=(
            mongodb-org
            mongodb-org-tools
        )
        
        install_packages "${packages[@]}"
        
        enable_and_start_service mongod
        
        # Install MongoDB Compass (GUI)
        if confirm_action "Install MongoDB Compass" "Official MongoDB GUI client"; then
            download_and_install "https://downloads.mongodb.com/compass/mongodb-compass_1.40.4_amd64.deb" "mongodb-compass.deb" "MongoDB Compass"
        fi
        
        print_success "MongoDB installed and configured"
    fi
}

# Install Redis
install_redis() {
    if confirm_install "Redis Database" "In-memory data structure store"; then
        print_section "Installing Redis"
        
        local packages=(
            redis-server
            redis-tools
        )
        
        install_packages "${packages[@]}"
        
        enable_and_start_service redis-server
        
        # Install Redis GUI clients
        if confirm_action "Install Redis Desktop Manager" "Redis GUI client"; then
            install_snap_packages redis-desktop-manager
        fi
        
        print_success "Redis installed and configured"
        print_info "Redis CLI: redis-cli"
        print_info "Redis config: /etc/redis/redis.conf"
    fi
}

# Install InfluxDB (Time Series Database)
install_influxdb() {
    if confirm_install "InfluxDB" "Time series database for metrics and analytics"; then
        print_section "Installing InfluxDB"
        
        # Add InfluxDB repository
        print_info "Adding InfluxDB repository..."
        curl -fsSL https://repos.influxdata.com/influxdata-archive_compat.key | gpg --dearmor -o /usr/share/keyrings/influxdata-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/influxdata-archive-keyring.gpg] https://repos.influxdata.com/debian stable main" | tee /etc/apt/sources.list.d/influxdata.list
        
        apt update >> "$LOG_FILE" 2>&1
        
        local packages=(
            influxdb2
            influxdb2-cli
        )
        
        install_packages "${packages[@]}"
        
        enable_and_start_service influxdb
        
        print_success "InfluxDB installed and configured"
        print_info "InfluxDB UI: http://localhost:8086"
    fi
}

# Install Elasticsearch
install_elasticsearch() {
    if confirm_install "Elasticsearch" "Distributed search and analytics engine"; then
        print_section "Installing Elasticsearch"
        
        # Add Elasticsearch repository
        print_info "Adding Elasticsearch repository..."
        curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" | tee /etc/apt/sources.list.d/elastic-8.x.list
        
        apt update >> "$LOG_FILE" 2>&1
        
        local packages=(
            elasticsearch
            kibana
            logstash
        )
        
        install_packages "${packages[@]}"
        
        # Configure Elasticsearch
        print_info "Configuring Elasticsearch..."
        {
            systemctl daemon-reload
            systemctl enable elasticsearch
            systemctl start elasticsearch
        } >> "$LOG_FILE" 2>&1
        
        print_success "Elasticsearch stack installed"
        print_info "Elasticsearch: http://localhost:9200"
        print_info "Kibana: http://localhost:5601"
        print_warning "Remember to configure security settings for production use"
    fi
}

# Install CouchDB
install_couchdb() {
    if confirm_install "Apache CouchDB" "NoSQL document database with HTTP API"; then
        print_section "Installing Apache CouchDB"
        
        # Add CouchDB repository
        print_info "Adding CouchDB repository..."
        curl -fsSL https://couchdb.apache.org/repo/keys.asc | gpg --dearmor -o /usr/share/keyrings/couchdb-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/couchdb-archive-keyring.gpg] https://apache.jfrog.io/artifactory/couchdb-deb/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/couchdb.list
        
        apt update >> "$LOG_FILE" 2>&1
        
        install_packages couchdb
        
        enable_and_start_service couchdb
        
        print_success "CouchDB installed and configured"
        print_info "CouchDB Fauxton UI: http://localhost:5984/_utils"
    fi
}

# Install Neo4j (Graph Database)
install_neo4j() {
    if confirm_install "Neo4j Graph Database" "Leading graph database for connected data"; then
        print_section "Installing Neo4j"
        
        # Add Neo4j repository
        print_info "Adding Neo4j repository..."
        curl -fsSL https://debian.neo4j.com/neotechnology.gpg.key | gpg --dearmor -o /usr/share/keyrings/neo4j-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/neo4j-keyring.gpg] https://debian.neo4j.com stable 5" | tee /etc/apt/sources.list.d/neo4j.list
        
        apt update >> "$LOG_FILE" 2>&1
        
        install_packages neo4j
        
        enable_and_start_service neo4j
        
        print_success "Neo4j installed and configured"
        print_info "Neo4j Browser: http://localhost:7474"
        print_info "Default username/password: neo4j/neo4j"
    fi
}

# Install database administration tools
install_db_admin_tools() {
    if confirm_install "Database Administration Tools" "GUI clients and command-line tools"; then
        print_section "Installing Database Administration Tools"
        
        local packages=(
            mycli
            pgcli
            litecli
            sqlite3
            mysql-workbench
            dbeaver-ce
        )
        
        # Install CLI tools first
        install_packages mycli pgcli litecli
        
        # Install MySQL Workbench
        if confirm_action "Install MySQL Workbench" "Visual database design tool"; then
            install_packages mysql-workbench
        fi
        
        # Install DBeaver
        if confirm_action "Install DBeaver" "Universal database tool"; then
            download_and_install "https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb" "dbeaver.deb" "DBeaver"
        fi
        
        # Install DataGrip (JetBrains) via snap
        if confirm_action "Install DataGrip" "Professional database IDE (requires license)"; then
            install_snap_packages datagrip --classic
        fi
        
        # Install Adminer (web-based)
        if confirm_action "Install Adminer" "Web-based database management"; then
            print_info "Installing Adminer..."
            mkdir -p /var/www/html/adminer
            curl -L "https://www.adminer.org/latest.php" -o /var/www/html/adminer/index.php
            print_success "Adminer installed at /var/www/html/adminer/"
            print_info "Access via web server at: http://localhost/adminer/"
        fi
    fi
}

# Install database migration and backup tools
install_db_migration_tools() {
    if confirm_install "Database Migration & Backup Tools" "Schema migration and backup utilities"; then
        print_section "Installing Database Migration & Backup Tools"
        
        # Install Flyway (database migration tool)
        if confirm_action "Install Flyway" "Database migration tool"; then
            print_info "Installing Flyway..."
            local flyway_version="9.22.3"
            download_and_install "https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/${flyway_version}/flyway-commandline-${flyway_version}-linux-x64.tar.gz" "flyway.tar.gz" "Flyway"
            
            if [ -f "/tmp/setup-downloads/flyway.tar.gz" ]; then
                tar -xzf "/tmp/setup-downloads/flyway.tar.gz" -C /opt/
                ln -sf "/opt/flyway-${flyway_version}/flyway" /usr/local/bin/flyway
                print_success "Flyway installed"
            fi
        fi
        
        # Install Liquibase (database change management)
        if confirm_action "Install Liquibase" "Database change management"; then
            print_info "Installing Liquibase..."
            local liquibase_version="4.24.0"
            download_and_install "https://github.com/liquibase/liquibase/releases/download/v${liquibase_version}/liquibase-${liquibase_version}.tar.gz" "liquibase.tar.gz" "Liquibase"
            
            if [ -f "/tmp/setup-downloads/liquibase.tar.gz" ]; then
                mkdir -p /opt/liquibase
                tar -xzf "/tmp/setup-downloads/liquibase.tar.gz" -C /opt/liquibase/
                ln -sf /opt/liquibase/liquibase /usr/local/bin/liquibase
                print_success "Liquibase installed"
            fi
        fi
        
        # Install database backup tools
        local backup_packages=(
            mysqldump
            pg_dump
            xtrabackup
            mydumper
        )
        
        for package in "${backup_packages[@]}"; do
            if ! is_package_installed "$package"; then
                case "$package" in
                    mysqldump) install_packages mysql-client ;;
                    pg_dump) install_packages postgresql-client ;;
                    xtrabackup) install_packages percona-xtrabackup-24 ;;
                    mydumper) install_packages mydumper ;;
                esac
            fi
        done
    fi
}

# Install database drivers and connectors
install_db_drivers() {
    if confirm_install "Database Drivers & Connectors" "Language-specific database drivers"; then
        print_section "Installing Database Drivers & Connectors"
        
        # Python drivers
        local python_drivers=(
            python3-psycopg2
            python3-pymysql
            python3-redis
            python3-pymongo
        )
        
        install_packages "${python_drivers[@]}"
        
        # ODBC drivers
        local odbc_packages=(
            unixodbc
            unixodbc-dev
            odbc-postgresql
            odbc-mariadb
        )
        
        install_packages "${odbc_packages[@]}"
        
        # JDBC drivers (if Java is installed)
        if command_exists java; then
            print_info "Java detected, installing JDBC drivers..."
            local jdbc_packages=(
                libpostgresql-jdbc-java
                libmariadb-java
            )
            install_packages "${jdbc_packages[@]}"
        fi
    fi
}

# Configure database performance monitoring
setup_db_monitoring() {
    if confirm_install "Database Monitoring Tools" "Performance monitoring and metrics collection"; then
        print_section "Setting up Database Monitoring"
        
        # Install Prometheus Node Exporter
        if confirm_action "Install Prometheus Node Exporter" "System metrics collector"; then
            local packages=(
                prometheus-node-exporter
            )
            install_packages "${packages[@]}"
            enable_and_start_service prometheus-node-exporter
        fi
        
        # Install Grafana
        if confirm_action "Install Grafana" "Metrics visualization dashboard"; then
            # Add Grafana repository
            curl -fsSL https://packages.grafana.com/gpg.key | gpg --dearmor -o /usr/share/keyrings/grafana-keyring.gpg
            echo "deb [signed-by=/usr/share/keyrings/grafana-keyring.gpg] https://packages.grafana.com/oss/deb stable main" | tee /etc/apt/sources.list.d/grafana.list
            
            apt update >> "$LOG_FILE" 2>&1
            install_packages grafana
            
            enable_and_start_service grafana-server
            print_success "Grafana installed"
            print_info "Grafana UI: http://localhost:3000 (admin/admin)"
        fi
        
        # Install pgBadger for PostgreSQL log analysis
        if is_package_installed postgresql; then
            install_packages pgbadger
            print_info "pgBadger installed for PostgreSQL log analysis"
        fi
    fi
}

# Main databases module execution
main() {
    print_header "Database Systems Installation"
    
    install_sqlite
    install_postgresql
    install_mysql
    install_redis
    install_mongodb
    install_influxdb
    install_elasticsearch
    install_couchdb
    install_neo4j
    install_db_admin_tools
    install_db_migration_tools
    install_db_drivers
    setup_db_monitoring
    
    print_success "Database systems installation completed"
    
    # Database recommendations
    echo -e "\n${BOLD}${YELLOW}Database Recommendations:${RESET}"
    echo -e "${CYAN}• Secure MySQL/MariaDB: mysql_secure_installation${RESET}"
    echo -e "${CYAN}• Set PostgreSQL password: sudo -u postgres psql -c \"\\password postgres\"${RESET}"
    echo -e "${CYAN}• Configure database backups with cron jobs${RESET}"
    echo -e "${CYAN}• Monitor database performance and logs${RESET}"
    echo -e "${CYAN}• Use database-specific configuration tuning${RESET}"
    echo -e "${CYAN}• Set up SSL/TLS for production databases${RESET}"
}

# Execute main function
main
