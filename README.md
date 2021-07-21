# galaxy-pulsar-dev

## Overview

A [Docker Compose][docker-compose]-based solution for easing the development and testing of [Pulsar][pulsar] with
[Galaxy][galaxy].

Most development setups are not going to find the sorts of bugs that commonly occur in production since in development,
all paths are on the same host and accessible to both the Galaxy and Pulsar servers, which run as the same user.
**galaxy-pulsar-dev** exists to develop and test your changes on a production-like setup, with RabbitMQ and
privilege/host separation.

In addition, Galaxy and Pulsar are tightly coupled (Galaxy imports Pulsar libs, Pulsar imports Galaxy libs). This
project makes it easy to run your changes to the Pulsar client library in Galaxy.

This project evolved from a [single script][single-script] created in preparation for the Galaxy Community Conference
2021 CoFest.

## Usage

To start, run:

```console
$ make up
```

This does a bit of one-time preparation:

- Creating the Docker Compose `.env` file
- Cloning Galaxy and Pulsar at `../galaxy` and `../pulsar`, respectively
- Creating Galaxy's virtualenv at `galaxy/venv` and installing its dependencies
- Building Galaxy's client, if necessary

After which, it runs `docker-compose up`. As is normal with foreground Docker Compose sessions, hit `Ctrl-C` to
terminate. To start daemonized, run:

```console
$ make up-d
```

And to stop:

```console
$ make down
```

Once the one-time setup has been performed, you can forego the Makefile and run `docker-compose` commands directly, if
you prefer.

It is often ideal to leave PostgreSQL and RabbitMQ running while only restarting Galaxy and/or Pulsar, especially since
no persistence is configured for PostgreSQL (intentionally). After starting (daemonized, or from another terminal), you
can restart Galaxy and Pulsar with:

```console
$ make restart
```

Or you can restart individual services like so:

```console
$ docker-compose restart galaxy-web galaxy-job  # restart Galaxy
$ docker-compose restart pulsar                 # restart Pulsar
```

To reset to the initial state, run:

```console
$ make clean
```

This removes `.env`, the virtualenvs, and Galaxy and Pulsar state directories, but not the Galaxy and Pulsar clones
(even if it created them). It also removes the Docker containers and images.

## pulsar-galaxy-lib

Pulsar's client library is installed in Galaxy at a pinned version from the packages on PyPI, but it is often desirable
when developing to install the Pulsar client library from your development clone of Pulsar instead. This can be acheived
by running:

```console
$ make pulsar-galaxy-lib
```

The [single script][single-script] version of this project attempted to do this step for you automatically as-needed,
but that's a bit harder to do in the Compose setup, so you have to trigger it manually for now.

## Customization

To use Galaxy and/or Pulsar clones at different (perhaps preexisting) paths, generate `.env` first with:

```console
$ make .env
```

Then edit `.env` and set `$GALAXY_ROOT` and/or `$PULSAR_ROOT` accordingly.

## Additional Notes

The directory `galaxy/config/` is mounted into the container over Galaxy's config directory, so you can make changes to
Galaxy's config there as needed.

These Galaxy users may be useful (you need to register them yourself):
  - admin@example.org: Galaxy Admin
  - local@example.org: Runs all jobs locally
  - pulsar@example.org: Runs all jobs (except upload1) via Pulsar

To query the database, you can use:

```console
$ docker-compose exec postgres psql -U galaxy -w galaxy
```

[docker-compose]: https://docs.docker.com/compose/
[pulsar]: https://github.com/galaxyproject/pulsar/
[galaxy]: https://github.com/galaxyproject/galaxy/
[single-script]: https://gist.github.com/natefoo/f4ddd72f1a07a70f6703d1b640deef17
