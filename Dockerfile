FROM registry.redhat.io/ubi9/ubi-minimal:9.5-1745855087

ENV NAME=nginx \
    NGINX_VERSION=1.24 \
    NGINX_SHORT_VER=124 \
    VERSION=0

ENV SUMMARY="Platform for running nginx $NGINX_VERSION or building nginx-based application"
ENV CREDIT="Original Dockerfile sourced from https://catalog.redhat.com/software/containers/ubi9/nginx-124/657b066b6c1bc124a1d7ff39?container-tabs=dockerfile \
            Updates were made to this file based on the requirement to host nginx container in custom environment such as VPS or AWS instance"
ENV NGINX_CONFIGURATION_PATH=${APP_ROOT}/etc/nginx.d \
    NGINX_CONF_PATH=/etc/nginx/nginx.conf \
    NGINX_DEFAULT_CONF_PATH=${APP_ROOT}/etc/nginx.default.d \
    NGINX_CONTAINER_SCRIPTS_PATH=/usr/share/container-scripts/nginx \
    NGINX_APP_ROOT=${APP_ROOT} \
    NGINX_LOG_PATH=/var/log/nginx \
    NGINX_PERL_MODULE_PATH=${APP_ROOT}/etc/perl

ARG INSTALL_PKGS="nss_wrapper-libs bind-utils gettext hostname nginx nginx-mod-stream nginx-mod-http-perl augeas-libs python3.12-pip"
ARG USERID=1001
ARG CERTBOT=".certbot"

LABEL name="" \
      vendor="" \
      version="1" \
      release="1" \
      summary="Nginx container to host ..." \
      description="Nginx container to host ..."

RUN microdnf -y module enable nginx:$NGINX_VERSION && \
    microdnf install -y --setopt=tsflags=nodocs $INSTALL_PKGS 
RUN rpm -V $INSTALL_PKGS && \
    nginx -v 2>&1 | grep -qe "nginx/$NGINX_VERSION\." && echo "Found VERSION $NGINX_VERSION" && \
    microdnf -y clean all --enablerepo='*'

COPY nginxconf.sed ${NGINX_APP_ROOT}
RUN sed -i -f ${NGINX_APP_ROOT}/nginxconf.sed ${NGINX_CONF_PATH} && \
    mkdir -p ${NGINX_APP_ROOT}/etc/nginx.d/ && \
    mkdir -p ${NGINX_APP_ROOT}/etc/nginx.default.d/ && \
    mkdir -p ${NGINX_APP_ROOT}/src/nginx-start/ && \
    mkdir -p ${NGINX_CONTAINER_SCRIPTS_PATH}/nginx-start && \
    mkdir -p ${NGINX_LOG_PATH} && \
    mkdir -p ${NGINX_PERL_MODULE_PATH} && \
    mkdir -p ${CERTBOT} &&\
    chown -R ${USERID}:0 ${CERTBOT} &&\
    chown -R ${USERID}:0 ${NGINX_CONF_PATH} && \
    chown -R ${USERID}:0 ${NGINX_APP_ROOT}/etc && \
    chown -R ${USERID}:0 ${NGINX_APP_ROOT}/src/nginx-start/  && \
    chown -R ${USERID}:0 ${NGINX_CONTAINER_SCRIPTS_PATH}/nginx-start && \
    chown -R ${USERID}:0 /var/lib/nginx /var/log/nginx /run && \
    chmod    ug+rw  ${NGINX_CONF_PATH} && \
    chmod -R ug+rwX ${NGINX_APP_ROOT}/etc && \
    chmod -R ug+rwX ${NGINX_APP_ROOT}/src/nginx-start/  && \
    chmod -R ug+rwX ${NGINX_CONTAINER_SCRIPTS_PATH}/nginx-start && \
    chmod -R ug+rwX /var/lib/nginx /var/log/nginx /run

# Deploy certbot 
# Ref - https://certbot.eff.org/instructions?ws=nginx&os=pip
RUN python3.12 -m pip install certbot certbot-nginx

EXPOSE 8080
EXPOSE 8443

USER ${USERID}
WORKDIR ${APP_ROOT}

STOPSIGNAL SIGQUIT
CMD ["nginx", "-g", "daemon off;"]
