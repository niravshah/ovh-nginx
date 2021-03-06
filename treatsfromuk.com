server {
	
     	listen 80;
	server_name www.treatsfromuk.com treatsfromuk.com;

 	# redirect all urls to https
    	return 301 https://$server_name$request_uri;
}

# HTTPS server
#
server {
	listen 443;
	server_name treatsfromuk.com www.treatsfromuk.com;

	ssl on;

 	# add Strict-Transport-Security to prevent man in the middle attacks
    	add_header Strict-Transport-Security "max-age=31536000";

    	# ssl certificate config
    	ssl_certificate /etc/letsencrypt/live/treatsfromuk.com/fullchain.pem;
    	ssl_certificate_key /etc/letsencrypt/live/treatsfromuk.com/privkey.pem;

   	access_log /var/log/nginx/treatsfromuk.com.log;

	ssl_session_timeout 5m;

	location / {

      		proxy_set_header X-Real-IP $remote_addr;
        	proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        	proxy_set_header Host $http_host;
        	proxy_set_header X-NginX-Proxy true;
        	proxy_pass http://127.0.0.1:8085;
        	proxy_redirect off;
        	proxy_http_version 1.1;
        	proxy_set_header Upgrade $http_upgrade;
        	proxy_set_header Connection "upgrade";
	}
}
