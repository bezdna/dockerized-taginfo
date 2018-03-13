.PHONY: all

all: refresh build

test: build testdatainit init ca-zz-genservices ca-zz-test peakcheck

refresh:
	docker pull abiosoft/caddy
	docker pull ruby:2.5-alpine3.7
	docker pull jwilder/nginx-proxy
	docker pull jwilder/whoami
	docker pull mdillon/postgis:10
	docker pull ubuntu:18.04

build:
	cd ./docker && docker build -t taginfo_job  -f taginfo_job.Dockerfile  . && cd ..
	cd ./docker && docker build -t taginfo_view -f taginfo_view.Dockerfile . && cd ..
	docker images | grep taginfo

dev:
	docker-compose run --rm taginfo_dev /bin/bash

dev_view: 
	docker run -it --rm taginfo_view sh


cleanold:
	sudo rm  ./service/*/*/data/old/* 
	sudo rm  ./service/*/*/input/area.osm.pbf 
	df -h | grep /dev	

down:
	docker-compose down

testdatainit:
	cp ./testdata/planet.osm.pbf  ./import_admin/
	cp ./testdata/NE1_50M_SR.zip  ./ne/
	cd ./ne && unzip NE1_50M_SR.zip  
	cp ./ne/NE1_50M_SR/NE1_50M_SR.tif  ./ne/ne.tif
	cp ./ne/NE1_50M_SR/NE1_50M_SR.prj  ./ne/ne.prj
	cp ./ne/NE1_50M_SR/NE1_50M_SR.tfw  ./ne/ne.tfw
	ls ./ne/* -la

ca-zz-genservices:
	./taginfo_genconfig.sh  central-america    zz  30000


ca-zz-test:
	cd ./service/zz && ./service_create.sh 	&& cd ../..   
	cd ./service/zz && ./service_job.sh     && cd ../..   
	cd ./service/zz && ./service_down.sh 	&& cd ../.. 


naturalearth:
	docker-compose run --rm -T taginfo_dev /osm/setup/natural_earth_download.sh 

init:
	docker-compose run --rm -T taginfo_dev /osm/setup/init.sh

genservices:
	./taginfo_genconfig.sh  africa             af  10000
	./taginfo_genconfig.sh  antarctica         aq  12000
	./taginfo_genconfig.sh  asia               as  14000
	./taginfo_genconfig.sh  australia-oceania  ao  16000
	./taginfo_genconfig.sh  central-america    ca  18000
	./taginfo_genconfig.sh  europe             eu  20000
	./taginfo_genconfig.sh  north-america      na  22000
	./taginfo_genconfig.sh  russia             ru  24000
	./taginfo_genconfig.sh  south-america      sa  26000








af-genservices:
	./taginfo_genconfig.sh  africa             af  10000
	
ca-genservices:	
	./taginfo_genconfig.sh  central-america    ca  18000

ao-genservices:
	./taginfo_genconfig.sh  australia-oceania  ao  16000

ru-genservices:
	./taginfo_genconfig.sh  russia             ru  24000

aq-genservices:
	./taginfo_genconfig.sh  antarctica         aq  12000

genproxy:
	docker-compose run  --rm -T taginfo_dev  /osm/setup/genhugo.sh

startproxy:
	pushd  ./service/ca
	docker-compose  -f docker-compose-proxy.yml  up -d
	popd


service-create:
	cd ./service/af && ./service_create.sh 	&& cd ../..   
	cd ./service/ao && ./service_create.sh 	&& cd ../..   
	cd ./service/aq && ./service_create.sh 	&& cd ../..   
	cd ./service/as && ./service_create.sh 	&& cd ../..   
	cd ./service/ca && ./service_create.sh 	&& cd ../..   
	cd ./service/eu && ./service_create.sh 	&& cd ../..   
	cd ./service/na && ./service_create.sh 	&& cd ../..   
	cd ./service/ru && ./service_create.sh 	&& cd ../..   
	cd ./service/sa && ./service_create.sh 	&& cd ../.. 

service-up:
	cd ./service/af && ./service_up.sh 		&& cd ../..   
	cd ./service/ao && ./service_up.sh 		&& cd ../..   
	cd ./service/aq && ./service_up.sh 		&& cd ../..  
	cd ./service/as && ./service_up.sh 		&& cd ../..   
	cd ./service/ca && ./service_up.sh 		&& cd ../..   
	cd ./service/eu && ./service_up.sh 		&& cd ../..   
	cd ./service/na && ./service_up.sh 		&& cd ../..   
	cd ./service/ru && ./service_up.sh 		&& cd ../..   
	cd ./service/sa && ./service_up.sh 		&& cd ../.. 

service-down:
	cd ./service/af && ./service_down.sh 	&& cd ../..   
	cd ./service/ao && ./service_down.sh 	&& cd ../..   
	cd ./service/aq && ./service_down.sh 	&& cd ../..   
	cd ./service/as && ./service_down.sh 	&& cd ../..   
	cd ./service/ca && ./service_down.sh 	&& cd ../..   
	cd ./service/eu && ./service_down.sh 	&& cd ../..   
	cd ./service/na && ./service_down.sh 	&& cd ../..   
	cd ./service/ru && ./service_down.sh 	&& cd ../..   
	cd ./service/sa && ./service_down.sh 	&& cd ../.. 

service-job:
	cd ./service/af && ./service_job.sh  && cd ../..   
	cd ./service/ao && ./service_job.sh  && cd ../..   
	cd ./service/aq && ./service_job.sh  && cd ../..  
	cd ./service/as && ./service_job.sh  && cd ../..   
	cd ./service/ca && ./service_job.sh  && cd ../..   
	cd ./service/eu && ./service_job.sh  && cd ../..   
	cd ./service/na && ./service_job.sh  && cd ../..   
	cd ./service/ru && ./service_job.sh  && cd ../..   
	cd ./service/sa && ./service_job.sh  && cd ../.. 


peakcheck:
	cat ./service/*/*/sources/log/*.log | grep peak:  | cut -d':' -f3 | sort -h | uniq

dockerstat:
	docker stats --format "table {{.Name}}\t {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"



