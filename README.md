* Simple way to launch container
* Map tag from ubi9-minimal container for our container as well, this is just for the simplicity

# podman build . -t 9.5-1745932134
# podman images

* Launch new nginx container
# podman run  -d -ti  --name my-nginx-124-9.5-1745932134 -p 80:8081 -p 443:4431 -v ~/git/public_html/dist:/opt/app-root/src -v ~/git/nginx/sites-available:/opt/app-root/etc/nginx.d/  localhost/my-nginx-124:9.5-1745932134
