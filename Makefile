#	project name
name	:= inception

#	volume paths
HOME			?= /tmp
mariadb_vol		:= $(HOME)/data/mariadb
wordpress_vol	:= $(HOME)/data/wordpress

#	service names
services_nginx		:= nginx
services_mariadb	:= mariadb
services_wordpress	:= wordpress


#	run docker compose
all:	create
create:	${mariadb_vol} ${wordpress_vol}
	cd srcs && docker compose -p $(name) up -d


#	create volume directories
${mariadb_vol}:
	mkdir -p ${mariadb_vol}
${wordpress_vol}:
	mkdir -p ${wordpress_vol}


#	cleanup	
stop:
#	if a container with inception_ prefix is found, iterate through every possible container and stop it
	@if [ -n "$$(docker ps -q -f name=$(name))" ]; then \
		nginx_containers="$$(docker ps -q -f name=$(name)-$(services_nginx)-)"; \
		wordpress_containers="$$(docker ps -q -f name=$(name)-$(services_wordpress)-)"; \
		mariadb_containers="$$(docker ps -q -f name=$(name)-$(services_mariadb)-)"; \
		for container in $$nginx_containers $$wordpress_containers $$mariadb_containers; do \
			docker stop $$container; \
		done \
	else \
		echo "make stop: no containers are currently active"; \
	fi

clean:	stop
#	delete inception related container
	@if [ -n "$$(docker ps -a -q -f name=$(name))" ]; then \
		mariadb_containers="$$(docker ps -a -q -f name=$(name)-$(services_mariadb)-)"; \
		wordpress_containers="$$(docker ps -a -q -f name=$(name)-$(services_wordpress)-)"; \
		nginx_containers="$$(docker ps -a -q -f name=$(name)-$(services_nginx)-)"; \
		for container in $$mariadb_containers $$wordpress_containers $$nginx_containers; do \
			docker rm $$container; \
		done \
	else \
		echo "make clean: no containers were found, skipping..."; \
	fi

#	delete inception related images
	@if [ -n "$$(docker images -aqf reference=$(name)-$(services_nginx))" ]; then \
		docker rmi $$(docker images -aqf reference=$(name)-$(services_nginx)); \
	else \
		echo "make clean: no images related to $(services_nginx) were found, skipping..."; \
	fi
	@if [ -n "$$(docker images -aqf reference=$(name)-$(services_wordpress))" ]; then \
		docker rmi $$(docker images -aqf reference=$(name)-$(services_wordpress)); \
	else \
		echo "make clean: no images related to $(services_wordpress) were found, skipping..."; \
	fi
	@if [ -n "$$(docker images -aqf reference=$(name)-$(services_mariadb))" ]; then \
		docker rmi $$(docker images -aqf reference=$(name)-$(services_mariadb)); \
	else \
		echo "make clean: no images related to $(services_mariadb) were found, skipping..."; \
	fi

#	'remove' docker volumes
	@if [ -n "$$(docker volume ls -qf name=$(name))" ]; then \
		wordpress_volume="$$(docker volume ls -qf name=$(name)_$(services_wordpress))"; \
		mariadb_volume="$$(docker volume ls -qf name=$(name)_$(services_mariadb)_vol)"; \
		for volume in $$wordpress_volume $$mariadb_volume; do \
			docker volume rm $$volume; \
		done \
	else \
		echo "make clean: no containers were found, skipping..."; \
	fi

fclean:	clean
	sudo rm -rf ${HOME}/data

re:	fclean all

.PHONY:	all create clean stop re