## Docker Container For NDC ##

The idea is to be able to run complete NDC solution in a containazied environment and share the NDC's output with other solutions running on docker.

In this solution we have kept a telemetry data simulator for ndc solution so that it will process the telemetry feed and share across the host machine and other solutions using:
* "ndc_export" folder
* brodcasting via "mqtt per minute feed"
* displaying realtime telemetry feed in "chronograf dashboard"

### Requirement ###

* A linux host machine with docker installed.
* Intially internet is required to install basic requirement while creating base image.


### Shared Volumes with docker and host machine ###

Creating a docker volumes to retain the data & configurations once the containers are down.

   volumes name : Information
*  ndc_data_vol : For ndc scripts, config & log files
*  influx_vol   : Influxdb data 
*  chrono_vol   : Chronograf dashboard
*  influx_conf  : Influxdb configuration
*  mosquitto_vol: Mosquitto configuration,log & broker data

**Note: Before running the containers make sure respective volumes are created.**


## Docker Static network Vs. Bridge host network ###

If a linux host machine has a address assigned let's say "172.16.0.10" and we want to assign the same IP address to all NDC containers then in "docker-compose.yaml" file under each service section choose *network-mode : "host"*

On other hand if we want each container to have a specific static address whenever it runs, then follow the custom network creation and assign IP address to each container under services. Also add the required ports which are used by the containers so that they will be exposed to host machine to exchange data. 

### Docker Container Services ###

* base_image 		: Used to build base ndc image from dockerfile
* influxdb   		: influxdb containter 						(static-ip: 172.16.0.10 port: 8086)
* influx-QL 		: apply continuous queries to influxdb 		(static-ip: 172.16.0.21 port: 8086)
* modbus_simulator  : sending nplc data   						(static-ip: 172.16.0.20 port: 502)
* modbus-nplc       : reading nplc data 						(static-ip: 172.16.0.23 port: 502)
* rt-calculated		: calculation for all realtime tags			(static-ip: 172.16.0.24 port: 502)
* rt-counter		: calculation for realtime counters			(static-ip: 172.16.0.25 port: 502)
* cron-export		: cronjob & share export folder 			(static-ip: 172.16.0.27 port: 445,139)
* mqtt-broker		: mqtt-broker								(static-ip: 172.16.0.29 port: 1883)
* ndc-publisher		: publisher per min realtime data 			(static-ip: 172.16.0.30 port: 1883)

More number of containers can be added according to need, few of them are pending like for navigational.

**Note: static address can be change according to need and can also be kept as same as host if required.**

### Static files to use along with all scripts and config files ###

* Dockerfile      : used to create ndc base image for containers.
* influxdb_1.7.1_amd64.deb : debian package for influxdb for ndc base image.
* QL-setup.sh     : used to apply QL files to influxdb.
* crontab.txt     : used to set cronjob for export scripts.
* cron_export.sh  : used to genrate s3db file and place in export folder.
* cron_archive.sh : used to archive older files.
* smb.conf 		  : used to configure samba server to share ndc_export folder
* influxdb.conf   : used to set configuration for influxdb container

### Process ###

* Copy all python scripts in ndc_container folder.
* Copy all json configs in ndc_container folder.
* Update all json config files with IP address corresponding to respective container's IP address.
* Create new volumes if any by using docker-setup.sh
* Create new container if any in docker-compose.yaml file.
* run "docker-setup.sh"
* run "docker-compose up -d"
* run "docker ps" to check status of running containers


### Commands ###

* -$ docker-setup.sh      : before creating docker ndc image.
* -$ docker-compose build : create docker ndc image.
* -$ docker-compose up    : start containers.
* -$ docker-compose down  : stop running containers & network.
* -$ docker-compose restart <service-name> : to restart a particular container.
* -$ docker network inspect <network-name> : to check created network & assigned IPs.
* -$ docker ps    : check running containers
* -$ docker ps -a : check all containers
* -$ docker rm -f <container-id> : force remove container
* -$ docker images ls         : check all images
* -$ docker rmi -f <image-id> : force remove an image*
* -$ docker volume create <volume-name>
* -$ docker volume rm <volume-name>

