FROM python:3.7-alpine3.8

RUN apk upgrade --no-cache && apk add --no-cache uwsgi uwsgi-python3

# Fix missing "getrandom"
RUN apk add --no-cache musl\>1.1.20 --repository http://dl-cdn.alpinelinux.org/alpine/edge/main

RUN \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories && \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
  apk update && \
  apk add --no-cache \
    gcc musl-dev jpeg-dev zlib-dev libffi-dev cairo-dev pango-dev gdk-pixbuf \
    cairo ttf-freefont ttf-font-awesome && \
  pip3 install --upgrade pip && pip3 install cffi cssselect2 cairosvg cairocffi WeasyPrint gunicorn flask dumb-init

EXPOSE 80

WORKDIR /srv/weasyprint
COPY tools.py ./

ENTRYPOINT ["dumb-init", "--"]

ENV WEASY_APP=tools:prod
CMD gunicorn --bind 0.0.0.0:80 --timeout 90 --graceful-timeout 60 "$WEASY_APP"
