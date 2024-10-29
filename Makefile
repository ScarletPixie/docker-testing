#	include environment variables
include srcs/.env

#	project name
name	:= inception

#	helper defines
define print_error
	make --no-print-directory config-error config=$(1) 2> /dev/null
endef
define valid_certificate
	make --no-print-directory valid-certificate arg=$(1) 2> /dev/null
endef
define valid_file
	make --no-print-directory valid-file arg=$(1) 2> /dev/null
endef


###	MAIN RULES
########################### BUILD AND START CONTAINERS ##################################
all:	create																			#
create:	$(MARIADB_VOL) $(WORDPRESS_VOL) check-env check-config							#
	@cd srcs && docker compose -p $(name) up -d											#
#########################################################################################


############################# CREATE VOLUME FOLDERS #####################################
$(WORDPRESS_VOL):																		#
	mkdir -p $(WORDPRESS_VOL)															#
$(MARIADB_VOL):																			#
	mkdir -p $(MARIADB_VOL)																#
#########################################################################################


############################### RESTART SERVICES ########################################
stop:																					#
	@cd srcs && docker compose -p $(name) stop											#
start:																					#
	@cd srcs && docker compose -p $(name) start											#
restart:																				#
	@cd srcs && docker compose -p $(name) restart										#
#########################################################################################


################################# REMOVE STUFF ##########################################
clean:	stop
	@cd srcs && docker compose -p $(name) down --volumes --rmi all
fclean:	clean
	@if [ -n "$$(docker images -aqf 'reference=inception*')" ]; then \
		$(MAKE) --no-print-directory force-delete; \
	fi
	sudo rm -rf ${HOME}/data
force-delete:
	docker rm -fv $$(docker ps -aqf 'name=$(name)') 2> /dev/null || true
	docker rmi -f $$(docker images -aqf 'reference=inception*') 2> /dev/null || true
	docker volume rm -f $$(docker volume ls -qf 'name=$(name)') 2> /dev/null || true
#########################################################################################


########################################## REBUILDING ###############################################
#	rebuild changed containers																		#
rebuild-service:																					#
	@ if [ -z "$(service)" ]; then echo "usage: make rebuild-service service=<name>"; exit 1; fi	#
	@cd srcs && docker compose -p $(name) up -d --build $(service)									#
rebuild-all-services:																				#
	@cd srcs && docker compose -p $(name) up -d --build												#
re:	fclean all																						#
#####################################################################################################


#	HELPER RULES
###################### CHECK IF ALL NECESSARY VARS ARE SET ##############################
check-env:																				#
	@test -n "$(USER)"				||	(echo "USER is not set" && exit 1)				#
	@test -n "$(DOMAIN_NAME)"		||	(echo "DOMAIN_NAME is not set" && exit 1)		#
	@test -n "$(MARIADB_VOL)"		||	(echo "MARIADB_VOL is not set" && exit 1)		#
	@test -n "$(WORDPRESS_VOL)"		||	(echo "WORDPRESS_VOL is not set" && exit 1)		#
	@test -n "$(MARIADB_USER)"		||	(echo "MARIADB_USER is not set" && exit 1)		#
	@test -n "$(MARIADB_DATADIR)"	||	(echo "MARIADB_DATADIR is not set" && exit 1)	#
	@test -n "$(WP_TITLE)"			||	(echo "WP_TITLE is not set" && exit 1)			#
#########################################################################################


############################### CHECK IF ALL NECESSARY SECRET FILES EXIST ###########################################
check-config:																										#
## MARIADB ##########################################################################################################
	@$(call valid_file, arg=secrets/db_root_password.txt)	||	$(call print_error, config=db_root_password.txt)	#
	@$(call valid_file, arg=secrets/db_user_password.txt)	||	$(call print_error, config=db_user_password.txt)	#
## WORDPRESS ########################################################################################################
	@$(call valid_file, arg=secrets/wp_admin_name.txt)		||	$(call print_error, config=wp_admin_name.txt)		#
	@$(call valid_file, arg=secrets/wp_admin_email.txt )	||	$(call print_error, config=wp_admin_email.txt)		#
	@$(call valid_file, arg=secrets/wp_admin_password.txt )	||	$(call print_error, config=wp_admin_password.txt)	#
	@$(call valid_file, arg=secrets/wp_user_name.txt )		||	$(call print_error, config=wp_user_name.txt)		#
	@$(call valid_file, arg=secrets/wp_user_email.txt )		||	$(call print_error, config=wp_user_email.txt)		#
	@$(call valid_file, arg=secrets/wp_user_password.txt )	||	$(call print_error, config=wp_user_password.txt)	#
## SSL CERTIFICATES #################################################################################################
	@$(call valid_certificate)																						#
#####################################################################################################################


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


#	HELPER RULES
create-secret:	#expected arguments: filepath=<path> content=<content>
	@if [ -z "$(filepath)" ]; then \
		echo "missing filepath!"; \
		exit 1; \
	fi
	@if [ ! -f "$(filepath)" ];	then \
		test -n "$(content)" || (echo "missing $(filepath) content!" && exit 1); \
		echo -n "$(content)" > "$(filepath)"; \
	else\
		echo "$(filepath) already exists, skipping..."; \
	fi

config-error:
	@file="$(config)" && \
	arg_name=$$(basename "$$file" .txt) && \
	printf "\e[31mERROR:\e[0m check if '\e[36msecrets/$$file exists\e[0m', \
	is not empty and does not have more than one line, you can make a new one by running 'make config $$arg_name=<value>'\n"
	@exit 1

valid-file:
	@export file_contents="$$(cat $(arg) | tr -d '[:space:]')" file_line_num="$$(wc -l < $(arg) | tr -d '\n')"; \
	if [ -z "$$file_contents" ] || [ -z "$$file_line_num" ] || [ "$$file_line_num" -gt 1 ] || [ "$$file_contents" != "$$(cat $(arg))" ]; then \
		exit 1; \
	fi

valid-certificate:
	@export cert="$$(cat secrets/wordpress.crt)" key="$$(cat secrets/wordpress.key)"; \
	if [ -z "$$cert" ] || [ -z "$$key" ]; then \
		echo "missing certificate"; \
		exit 1; \
	fi
	@export crt="$$(openssl x509 -noout -modulus -in secrets/wordpress.crt | openssl md5)" \
	key="$$(openssl rsa -noout -modulus -in secrets/wordpress.key | openssl md5)"; \
	if [ "$$crt" != "$$key" ]; then \
		echo "certificates don't match!"; \
		exit 1; \
	fi

####################################### MISC ##################################################
.PHONY:	all create clean stop start restart rebuild-service rebuild-all-services re \
		check-env check-config config create-secret config-error valid-file valid-certificate