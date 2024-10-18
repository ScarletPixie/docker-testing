#	Secrets Folder
This folder is destined to store sensitive information such as database password, credentials.

##	Mandatory files
The files below are ignored by git and are supposed to be either placed manually or passed as arguments to:
```bash
make config \
    db_user_password="<value>" \
    db_root_password="<value>" \
    wp_admin_password="<value>" \
    wp_user_password="<value>" \
    redis_password="<value>" \
    certificate-subj="/C=<country>/ST=<state>/L=<city>/O=<organization name>/OU=<organization unit (optional)>/CN=<domain name>"
```

###	mariadb credentials
-	db_user_password.txt
-	db_root_password.txt

###	wordpress credentials
-	wp_admin_password.txt
-	wp_user_password.txt

###	redis credentials
-	redis_password.txt

###	ssl certificates
-	&lt;domain name&gt;.crt
-	&lt;domain name&gt;.key