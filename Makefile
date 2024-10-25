#	include environment variables
include srcs/.env

#	project name
name	:= inception

#	service names
services_nginx		:= nginx
services_mariadb	:= mariadb
services_wordpress	:= wordpress

###	RULES
############################# BUILD AND START CONTAINERS ################################
all:	create																			#
#########################################################################################


######################### CHECK IF ALL NECESSARY VARS ARE SET ###########################
check-env:																				#
	@test -n "$(USER)"				||	(echo "USER is not set" && exit 1)				#
	@test -n "$(DOMAIN_NAME)"		||	(echo "DOMAIN_NAME is not set" && exit 1)		#
	@test -n "$(MARIADB_VOL)"		||	(echo "MARIADB_VOL is not set" && exit 1)		#
	@test -n "$(WORDPRESS_VOL)"		||	(echo "WORDPRESS_VOL is not set" && exit 1)		#
	@test -n "$(MARIADB_USER)"		||	(echo "MARIADB_USER is not set" && exit 1)		#
	@test -n "$(MARIADB_DATADIR)"	||	(echo "MARIADB_DATADIR is not set" && exit 1)	#
	@test -n "$(WP_TITLE)"			||	(echo "WP_TITLE is not set" && exit 1)			#
#########################################################################################

define print_error
	make --no-print-directory config-error config=$(1) 2> /dev/null
endef

######################################### CHECK IF ALL NECESSARY SECRET FILES EXIST #########################################
check-config:																												#
## MARIADB ##################################################################################################################
	@test -n "$$(cat secrets/db_root_password.txt 2> /dev/null)"	||	$(call print_error, config=db_root_password.txt)	#
	@test -n "$$(cat secrets/db_user_password.txt 2> /dev/null)"	||	$(call print_error, config=db_user_password.txt)	#
## WORDPRESS ################################################################################################################
	@test -n "$$(cat secrets/wp_admin_name.txt 2> /dev/null)"		||	$(call print_error, config=wp_admin_name.txt)		#
	@test -n "$$(cat secrets/wp_admin_email.txt  2> /dev/null)"		||	$(call print_error, config=wp_admin_email.txt)		#
	@test -n "$$(cat secrets/wp_admin_password.txt  2> /dev/null)"	||	$(call print_error, config=wp_admin_password.txt)	#
	@test -n "$$(cat secrets/wp_user_name.txt  2> /dev/null)"		||	$(call print_error, config=wp_user_name.txt)		#
	@test -n "$$(cat secrets/wp_user_email.txt  2> /dev/null)"		||	$(call print_error, config=wp_user_email.txt)		#
	@test -n "$$(cat secrets/wp_user_password.txt  2> /dev/null)"	||	$(call print_error, config=wp_user_password.txt)	#
## SSL CERTIFICATES #########################################################################################################
	@test -n "$$(find secrets -name wordpress.crt)"					||	$(call print_error, config=wordpress.crt)			#
	@test -n "$$(find secrets -name wordpress.key)"					||	$(call print_error, config=wordpress.key)			#
#############################################################################################################################



####################################### CREATE SECRET FILES FROM ARGS ######################################################
config:
	@$(MAKE) --no-print-directory create-secret filepath="secrets/db_root_password.txt" content="$(db_root_password)"
	@$(MAKE) --no-print-directory create-secret filepath="secrets/db_user_password.txt" content="$(db_user_password)"

	@$(MAKE) --no-print-directory create-secret filepath="secrets/wp_admin_name.txt" content="$(wp_admin_name)"
	@$(MAKE) --no-print-directory create-secret filepath="secrets/wp_admin_password.txt" content="$(wp_admin_password)"
	@$(MAKE) --no-print-directory create-secret filepath="secrets/wp_admin_email.txt" content="$(wp_admin_email)"

	@$(MAKE) --no-print-directory create-secret filepath="secrets/wp_user_name.txt" content="$(wp_user_name)"
	@$(MAKE) --no-print-directory create-secret filepath="secrets/wp_user_password.txt" content="$(wp_user_password)"
	@$(MAKE) --no-print-directory create-secret filepath="secrets/wp_user_email.txt" content="$(wp_user_email)"

#	ssl certificate
	@if [ ! -f "secrets/wordpress.crt" ] || [ ! -f "secrets/wordpress.key" ]; then \
		echo "creating ssl certificates..."; \
		if [ -z "$(certificate_subj)" ]; then \
			echo "missing certificate subject parameter!" && exit 1; \
		fi; \
		openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
			-keyout "secrets/wordpress.key" -out "secrets/wordpress.crt" \
			-subj "$(certificate_subj)"; \
	else\
		echo "ssl certificate already exists, skipping..."; \
	fi
############################################################################################################################


########################## BUILD AND START CONTAINERS ###################################
create:	$(MARIADB_VOL) $(WORDPRESS_VOL) check-env check-config							#
	@docker swarm init 2> /dev/null || echo "already in swarm mode, skipping..."		#
	@cd srcs && docker compose -p $(name) up -d											#
#########################################################################################


############################# CREATE VOLUME FOLDERS #####################################
$(WORDPRESS_VOL):																		#
	mkdir -p $(WORDPRESS_VOL)															#
$(MARIADB_VOL):																			#
	mkdir -p $(MARIADB_VOL)																#
#########################################################################################


######################################## STOP SERVICES ######################################################
stop:
	@docker swarm leave --force 2> /dev/null || echo "swarm mode already off, skipping...."
	@if [ -n "$$(docker ps -q -f name=$(name))" ]; then \
		nginx_containers="$$(docker ps -q -f name=$(name)_$(services_nginx))"; \
		wordpress_containers="$$(docker ps -q -f name=$(name)_$(services_wordpress))"; \
		mariadb_containers="$$(docker ps -q -f name=$(name)_$(services_mariadb))"; \
		for container in $$nginx_containers $$wordpress_containers $$mariadb_containers; do \
			docker stop $$container; \
		done \
	else \
		echo "make stop: no containers are currently active"; \
	fi
#############################################################################################################


#################################### REMOVE CONTAINERS ########################################################
clean:	stop
	@if [ -n "$$(docker ps -a -q -f name=$(name))" ]; then \
		mariadb_containers="$$(docker ps -a -q -f name=$(name)_$(services_mariadb))"; \
		wordpress_containers="$$(docker ps -a -q -f name=$(name)_$(services_wordpress))"; \
		nginx_containers="$$(docker ps -a -q -f name=$(name)_$(services_nginx))"; \
		for container in $$mariadb_containers $$wordpress_containers $$nginx_containers; do \
			docker rm $$container; \
		done \
	else \
		echo "make clean: no containers were found, skipping..."; \
	fi
#############################################################################################################


###################################### DELETE DATA ##########################################################
fclean:	clean
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
		wordpress_volume="$$(docker volume ls -qf name=$(name)_$(services_wordpress)_vol)"; \
		mariadb_volume="$$(docker volume ls -qf name=$(name)_$(services_mariadb)_vol)"; \
		for volume in $$wordpress_volume $$mariadb_volume; do \
			docker volume rm $$volume; \
		done \
	else \
		echo "make clean: no containers were found, skipping..."; \
	fi

#	remove docker networks
	@if [ -n "$$(docker network ls -qf name=$(name)_$(services_nginx)_to_host)" ]; then \
		docker network rm $(name)_$(services_nginx)_to_host; \
	else \
		echo "no nginx <-> host network set up, skipping..."; \
	fi
	@if [ -n "$$(docker network ls -qf name=$(name)_$(services_wordpress)_to_$(services_nginx))" ]; then \
		docker network rm $(name)_$(services_wordpress)_to_$(services_nginx); \
	else \
		echo "no wordpress <-> nginx network set up, skipping..."; \
	fi
	@if [ -n "$$(docker network ls -qf name=$(name)_$(services_mariadb)_to_$(services_wordpress))" ]; then \
		docker network rm $(name)_$(services_mariadb)_to_$(services_wordpress); \
	else \
		echo "no mariadb <-> wordpress network set up, skipping..."; \
	fi

	sudo rm -rf ${HOME}/data
#############################################################################################################


####### REBUILD #####
re:	fclean all		#
#####################


.PHONY:	all create clean stop re check-env check-config create-secret config-error

#	HELPER RULES
create-secret:	#expected arguments: filepath=<path> content=<content>
	@test -n "$(filepath)" || (echo "missing filepath!" && exit 1)
	@if [ ! -f "$(filepath)" ];	then \
		test -n "$(content)" || (echo "missing $(filepath) content!" && exit 1); \
		echo -n "$(content)" > "$(filepath)"; \
	else\
		echo "$(filepath) already exists, skipping..."; \
	fi

config-error:
	@file="$(config)" && \
	arg_name=$$(basename "$$file" .txt) && \
	echo "$$file not present in secrets folder, add it manually or run 'make config $$arg_name=<value>'"
	@exit 1