FROM python:3-alpine
LABEL AUTHOR "Dave Sperling <dsperling@smithmicro.com>"

ENV WEB2PY_ROOT=/opt/web2py
ENV WEB2PY_VERSION=

# overridable environment variables
ENV WEB2PY_PASSWORD=
ENV WEB2PY_ADMIN_SECURITY_BYPASS=
ENV UWSGI_OPTIONS=
ENV WEB2PY_SCHEDULER_APPS=

WORKDIR /opt

RUN apk update && apk add 
RUN apk update && apk add \
    postgresql-dev \
    gcc \
    python3-dev \
    musl-dev \
    build-base \
    linux-headers \
    pcre-dev \
    wget \
 && pip install --upgrade pip \
 && pip install uwsgi \
 && pip install psycopg2 \
 && wget http://web2py.com/examples/static/web2py_src.zip \
 && unzip web2py_src.zip \
 && rm web2py_src.zip \
 && mv $WEB2PY_ROOT/handlers/wsgihandler.py $WEB2PY_ROOT \
 && addgroup -g 1000 -S web2py \
 && adduser -u 1000 -S web2py -G web2py \
 && chown -R web2py:web2py $WEB2PY_ROOT

COPY entrypoint.sh /usr/local/bin/

WORKDIR $WEB2PY_ROOT

ENTRYPOINT [ "entrypoint.sh" ]
CMD [ "http" ]
USER web2py

EXPOSE 8080 9090
