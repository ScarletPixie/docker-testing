#	Secrets Folder
This folder is destined to store sensitive information such as database password, wordpress credentials.

##	Mandatory files
The files below are ignored by git and are supposed to be either placed manually or passed as arguments to:

```bash
make config \
	db_user_password="<value>" \
	db_root_password="<value>" \
	wp_admin_name="<value>" \
	wp_admin_password="<value>" \
	wp_admin_email="<value>" \
	wp_user_name="<value" \
	wp_user_password="<value>" \
	wp_user_email="<value>" \
	certificate_subj="/C=<country_code>/ST=<state>/L=<city>/O=<organization name>/OU=<organization unit (optional)>/CN=<domain name>"
```

###	mariadb credentials
-	db_user_password.txt
-	db_root_password.txt

###	wordpress credentials
-	wp_admin_name.txt
-	wp_admin_password.txt
-	wp_admin_email.txt
-	wp_user_name.txt
-	wp_user_password.txt
-	wp_user_email.txt

###	ssl certificates
-	wordpress.crt
-	wordpress.key

####	OBSERVATIONS
Only one line per file (one line with a break at the end is acceptable).