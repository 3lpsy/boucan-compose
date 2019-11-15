# About

This is a simple Compose project for managing and starting Boucan services. It's currently aimed at development and not delopment. The setup.sh script can be used for easy cloning and setting up new environments for testing. The compose.sh is a simple wrapper to allow for customized file locations. If you want to skip the setup and already have the repos cloned you can just do the following to get started manually:

```
$ cp compose.env.example compose.env
# configure the values appropriately
# don't run setup.sh if doing this
# you'll also need to setup HTTP_API_TOKEN and DNS_API_TOKEN
```

More documentation can be found here: [Boucan: A Bug Bounty Canary Platform](https://github.com/3lpsy/boucanpy)

## Developing

The goal of this project is to create a seamless development environment where changes to files on hosts are automatically propagated to running services inside the container.

For this reason, the dev compose project makes heavy use of volumes. You will want to familiarze yourself with what volumes are being used and the related Dockerfiles.

## Setup

**Please run from inside the Compose directory**

If you want to customize your setup without specifying the options on the CLI, you can do the following:

```
$ cp setup.env.example setup.env
```

Next, open env.source in a text editor and modify or remove the relevant variables.

By default, it will assume the parent of the current directory is the target. You can Specify a target directory to clone repos into with the following:

```
# using environment variables
$ BOUCAN_DIR=/home/youruser/boucan ./setup.sh

# using an argument
$ ./setup.sh /home/youruser/boucan
```

If you have all the branches forked, you can clone them with setup:

```
$ REPO_OWNER=3lpsy ./setup.sh;
$ REPO_BRANCH=master REPO_PREFIX=Special REPO_OWNER=3lpsy ./setup.sh;
```

You can read env.source.example for additional information about options.

## Running

The compose.sh script will pass all options after the env to the docker-compose command.

```
BucanCompose: A Compose Project for Boucan
Usage:
    $ ./compose.sh [env] [compose options]

Examples:
    $ ./compose.sh dev build --no-cache
    $ ./compose.sh dev down -v
    $ ./compose.sh dev up
    $ ./compose.sh dev fresh
```

There is a special command called fresh which is the equivalent of running:

```
$ ./compose.sh dev down -v && ./compose.sh dev up
```

### Firewalld

Probably not necessary for you.

```
$ firewall-cmd --permanent --zone=trusted --add-interface=boucanpub0
# probably optional
$ firewall-cmd --permanent --zone=trusted --add-interface=docker0
```
