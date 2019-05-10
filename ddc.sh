cd /vagrant
extra_files=`ls docker-compose.[0-9]*.yml | xargs echo | sed -e "s/docker/-f docker/g"`
docker-compose -f docker-compose.yml ${extra_files} $*