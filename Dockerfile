FROM alpine:3.14

WORKDIR /home/blackduck

RUN apk update && apk add --no-cache git bash curl jq python3 && ln -sf python3 /usr/bin/python

RUN python3 -m ensurepip

RUN pip3 install --no-cache --upgrade pip setuptools blackduck

COPY . /home/blackduck/

RUN chmod +x /home/blackduck/generate_report.sh

CMD bash /home/blackduck/generate_report.sh
