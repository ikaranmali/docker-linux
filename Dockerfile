# Download base image
FROM debian:stretch

RUN apt-get update && apt-get install -y \
    apt-utils\
    python3 \
    python3-pip \
    socat \
    nmap \
    curl \
    tar \
    nano \
    wget \
    git \
    samba \
    ufw \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /home

RUN pip3 install paho-mqtt pynmea2==1.12.0 pyserial==3.4 influxdb==5.2.0 pymodbus[twisted] libais==0.17

RUN wget https://www.modbusdriver.com/downloads/modpoll.tgz &&\
    tar -zxvf modpoll.tgz

COPY . /home/

RUN dpkg -i influxdb_1.7.1_amd64.deb 

RUN cp -v templates/smb.conf /etc/samba/

COPY crontab.txt /home/templates/crontab.txt

RUN crontab templates/crontab.txt

COPY cron_export.sh /home/

COPY cron_archive.sh /home/

RUN mkdir log tmp export 

RUN date 

RUN echo Setup done

