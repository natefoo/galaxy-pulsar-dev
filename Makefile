UID	:= $(shell id -u)
GID	:= $(shell id -g)


up: .env galaxy/venv
	docker-compose up

up-d: .env galaxy/venv
	docker-compose up -d

.env:
	sh ./.env.in

galaxy-venv:
	bash ./galaxy/build.sh

galaxy/venv: galaxy-venv

clean:
	rm -f .env
	rm -rf galaxy/venv galaxy/database
	git checkout galaxy/database/README

.PHONY: clean up galaxy-venv
