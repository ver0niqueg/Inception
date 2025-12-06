DEFAULT			= \033[0m
RED				= \033[1;31m
GREEN			= \033[1;32m
YELLOW			= \033[1;33m
BLUE			= \033[1;34m
MAGENTA			= \033[1;35m
CYAN			= \033[1;36m

COMPOSE_FILE = ./srcs/docker-compose.yml
DATA_PATH = /home/vgalmich/data
LOGIN = vgalmich

all:
				@mkdir -p $(DATA_PATH)/wordpress
				@mkdir -p $(DATA_PATH)/mariadb
				@if [ ! -d "secrets" ]; then \
					echo "$(YELLOW)No secrets found. Creating them...$(DEFAULT)\n"; \
					$(MAKE) setup; \
				fi
				@echo "\n$(GREEN)Starting Inception...$(DEFAULT)\n"
				@cd srcs && docker compose up -d --build
				@echo "\n$(GREEN)Inception is running!$(DEFAULT)"
				@echo "$(CYAN)Visit: https://$(LOGIN).42.fr$(DEFAULT)\n"

setup:
				@if [ ! -d "secrets" ]; then \
					echo "$(YELLOW)Creating secrets directory...$(DEFAULT)"; \
					mkdir -p secrets; \
					read -p "Enter database password: " db_pass; echo $$db_pass > secrets/db_password.txt; \
					read -p "Enter database root password: " db_root_pass; echo $$db_root_pass > secrets/db_root_password.txt; \
					read -p "Enter WordPress admin password: " wp_admin_pass; echo $$wp_admin_pass > secrets/wp_admin_password.txt; \
					read -p "Enter WordPress user password: " wp_user_pass; echo $$wp_user_pass > secrets/wp_user_password.txt; \
					echo "$(GREEN)✅ Secrets created!$(DEFAULT)"; \
				else \
					echo "$(GREEN)✅ Secrets directory already exists$(DEFAULT)"; \
				fi

up:
				@cd srcs && docker compose up -d
				@echo "\n✅ $(GREEN)Services started$(DEFAULT)\n"

down:
				@cd srcs && docker compose down
				@echo "\n❌ $(YELLOW)Services stopped$(DEFAULT)\n"

stop:
				@cd srcs && docker compose stop
				@echo "\n⏸️ $(YELLOW)Services paused$(DEFAULT)\n"

start:
				@cd srcs && docker compose start
				@echo "\n▶️ $(GREEN)Services resumed$(DEFAULT)\n"

status:
				@cd srcs && docker compose ps

logs:
				@cd srcs && docker compose logs -f

clean:			down
				@echo "🧹 $(RED)Cleaning containers and networks...$(DEFAULT)"
				@docker system prune -af
				@echo "✅ $(GREEN)Clean completed$(DEFAULT)\n"

fclean:			down
				@echo "🗑️ $(RED)Removing all containers, networks, images and volumes...$(DEFAULT)"
				@docker system prune -af --volumes
				@sudo rm -rf $(DATA_PATH)
				@rm -rf secrets
				@echo "✅ $(GREEN)Full clean completed$(DEFAULT)\n"

re:			fclean all

help:
				@echo "\n$(BLUE)setup$(DEFAULT)\t\t- Create secrets directory and files interactively"
				@echo "$(BLUE)all$(DEFAULT)\t\t- Build and start all services"
				@echo "$(BLUE)up$(DEFAULT)\t\t\t- Start all services"
				@echo "$(BLUE)down$(DEFAULT)\t\t\t- Stop all services"
				@echo "$(BLUE)stop$(DEFAULT)\t\t\t- Pause all services"
				@echo "$(BLUE)start$(DEFAULT)\t\t\t- Resume all services"
				@echo "$(BLUE)status$(DEFAULT)\t\t- Show services status"
				@echo "$(BLUE)logs$(DEFAULT)\t\t\t- Show and follow services logs"
				@echo "$(BLUE)clean$(DEFAULT)\t\t\t- Stop and remove containers/networks"
				@echo "$(BLUE)fclean$(DEFAULT)\t\t- Full cleanup (containers/networks/volumes/data)"
				@echo "$(BLUE)re$(DEFAULT)\t\t\t- Rebuild everything from scratch\n"

.PHONY:			setup all up down stop start status logs clean fclean re help
