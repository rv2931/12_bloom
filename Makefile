VERSION ?= 1.0.0

BLOOM_DEV_DOCKER = @docker run --name blomm-test  --mount type=bind,source="$(shell pwd)",target=/source_code --env-file ./.env.test --network=bloom_net
<<<<<<< Updated upstream
BLOOM_PRODUCTION_DOCKER = @docker run --mount type=bind,source="$(shell pwd)",target=/source_code --env-file ./.env --log-driver json-file --log-opt max-size=1g --log-opt max-file=3  --entrypoint /entrypoint.sh
=======
BLOOM_PRODUCTION_DOCKER = @docker run --mount type=bind,source="$(shell pwd)",target=/source_code --env-file ./.env --log-driver json-file --log-opt max-size=1g --log-opt max-file=3 --entrypoint /entrypoint.sh
>>>>>>> Stashed changes

build:
	@docker build -t d4g/bloom:${VERSION} --platform linux/amd64  -f docker-env/Dockerfile .
	@docker tag d4g/bloom:${VERSION} d4g/bloom:latest

launch-dev-db:
	@docker-compose -f docker-env/docker-compose-db.yaml up -d
	@sleep 10
	$(BLOOM_DEV_DOCKER) --rm d4g/bloom:${VERSION} alembic upgrade head
	$(BLOOM_DEV_DOCKER) --rm d4g/bloom:${VERSION} /venv/bin/python3 alembic/init_script/load_vessels_data.py

launch-dev-container:
	$(BLOOM_DEV_DOCKER) -dti  d4g/bloom:${VERSION} /bin/bash

launch-dev-app:
	$(BLOOM_DEV_DOCKER) --rm d4g/bloom:${VERSION} /venv/bin/python3 app.py

launch-test:
	$(BLOOM_DEV_DOCKER) --rm d4g/bloom:${VERSION} tox -vv

rm-dev-db:
	@docker-compose -f docker-env/docker-compose-db.yaml stop
	@docker-compose -f docker-env/docker-compose-db.yaml rm

rm-dev-env:
	@docker rm blomm-test

init-production:
	$(BLOOM_PRODUCTION_DOCKER) --name blomm-production-db-init --rm alembic upgrade head
	$(BLOOM_PRODUCTION_DOCKER) --name blomm-production-db-init --rm /venv/bin/python3 alembic/init_script/load_vessels_data.py

launch-production:
	$(BLOOM_PRODUCTION_DOCKER) --name bloom-production -d d4g/bloom:${VERSION} cron -f -L 2

launch-production-app:
	 $(BLOOM_PRODUCTION_DOCKER) --name blomm-production-app --rm d4g/bloom:${VERSION} /venv/bin/python3 app.py