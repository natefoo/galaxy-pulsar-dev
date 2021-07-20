# galaxy-pulsar-dev

## Overview

A [docker-compose][docker-compose]-based solution for easing the development and testing of [Pulsar][pulsar] with
[Galaxy][galaxy].

Most development setups are not going to find the sorts of bugs that commonly occur in production since in development,
all paths are on the same host and accessible to both the Galaxy and Pulsar servers, which run as the same user.
**galaxy-pulsar-dev** exists to develop and test your changes on a production-like setup, with RabbitMQ and
privilege/host separation.

In addition, Galaxy and Pulsar are tightly coupled (Galaxy imports Pulsar libs, Pulsar imports Galaxy libs). This
project makes it easy to run your changes to the Pulsar client library in Galaxy.

## Usage

To start, run:

```console
$ make up
```

This does a bit of one-time preparation:

- Creating the docker-compose `.env` file
- Cloning Galaxy and Pulsar at `../galaxy` and `../pulsar`, respectively
- Creating Galaxy's virtualenv at `galaxy/venv` and installing its dependencies
- Building Galaxy's client, if necessary

To use Galaxy and/or Pulsar clones at different paths, generate `.env` with:

```console
$ make .env
```

Then edit that file and set `$GALAXY_ROOT` and/or `$PULSAR_ROOT` accordingly.



FIXME:



Galaxy's `scripts/common_startup.sh` takes a while to run, even when it has no changes, so it is not run automatically.
If you need to run it again (e.g. 

## Configuration Notes

The directory `galaxy/config/` is mounted into the container over Galaxy's config directory, so you can make changes to
Galaxy's config there as needed.

These Galaxy users may be useful (you need to register them yourself):
  - admin@example.org: Galaxy Admin
  - local@example.org: Runs all jobs locally
  - pulsar@example.org: Runs all jobs (except upload1) via Pulsar


[docker-compose]: https://docs.docker.com/compose/
[pulsar]: https://github.com/galaxyproject/pulsar/
[galaxy]: https://github.com/galaxyproject/galaxy/
