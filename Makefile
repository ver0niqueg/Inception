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
				@echo "\n $(GREEN)Starting Inception...$(DEFAULT)\n"
				@mkdir -p $(DATA_PATH)/wordpress
				@mkdir -p $(DATA_PATH)/mariadb
				@docker compose -f $(COMPOSE_FILE) up -d --build
				@echo "\n✅ $(GREEN)Inception is running!$(DEFAULT)"
				@echo "🌐 Visit: $(CYAN)https://$(LOGIN).42.fr$(DEFAULT)\n"

up:
				@docker compose -f $(COMPOSE_FILE) up -d
				@echo "\n✅ $(GREEN)Services started$(DEFAULT)\n"

down:
				@docker compose -f $(COMPOSE_FILE) down
				@echo "\n❌ $(YELLOW)Services stopped$(DEFAULT)\n"

stop:
				@docker compose -f $(COMPOSE_FILE) stop
				@echo "\n⏸️ $(YELLOW)Services paused$(DEFAULT)\n"

start:
				@docker compose -f $(COMPOSE_FILE) start
				@echo "\n▶️ $(GREEN)Services resumed$(DEFAULT)\n"

status:
				@docker compose -f $(COMPOSE_FILE) ps

logs:
				@docker compose -f $(COMPOSE_FILE) logs -f

clean:			down
				@echo "🧹 $(RED)Cleaning containers and networks...$(DEFAULT)"
				@docker system prune -af
				@echo "✅ $(GREEN)Clean completed$(DEFAULT)\n"

fclean:			down
				@echo "🗑️ $(RED)Removing all containers, networks, images and volumes...$(DEFAULT)"
				@docker system prune -af --volumes
				@sudo rm -rf $(DATA_PATH)
				@echo "✅ $(GREEN)Full clean completed$(DEFAULT)\n"

re:			fclean all

help:
				@echo "\n$(BLUE)all$(DEFAULT)\t\t- Build and start all services"
				@echo "$(BLUE)up$(DEFAULT)\t\t\t- Start all services"
				@echo "$(BLUE)down$(DEFAULT)\t\t\t- Stop all services"
				@echo "$(BLUE)stop$(DEFAULT)\t\t\t- Pause all services"
				@echo "$(BLUE)start$(DEFAULT)\t\t\t- Resume all services"
				@echo "$(BLUE)status$(DEFAULT)\t\t- Show services status"
				@echo "$(BLUE)logs$(DEFAULT)\t\t\t- Show and follow services logs"
				@echo "$(BLUE)clean$(DEFAULT)\t\t\t- Stop and remove containers/networks"
				@echo "$(BLUE)fclean$(DEFAULT)\t\t- Full cleanup (containers/networks/volumes/data)"
				@echo "$(BLUE)re$(DEFAULT)\t\t\t- Rebuild everything from scratch\n"

.PHONY:			all up down stop start status logs clean fclean re help
