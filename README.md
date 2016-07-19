# tarantino - cross-service development environment generation

You've got a shiny new machine and you're fired up to start hacking on your product. Let Tarantino give birth to all of the services comprising your platform.

## Overview

Tarantino provides a handy set of commands for managing your platform development environment. Here are some of the areas where he'll help:

  + cloning required source control repositories and install npm dependencies (`clone`)
  + creating and running VMs for all required services (`create`)
  + quickly access the plaform APIs in your browser (`api`)
  + viewing real-time logs from each service (`logs`)
  + destroying VMs for all services (`destroy`)

By default, Tarantino will clone code into the `~/projects` directory. Docker containers running 360 services are executing the very files in your project directory - including any of your local modifications. The `TT_PROJECTS` environment variable can be used to change the project directory location.

## Installation

Install Tarantino by cloning this repository and running `sudo make install`. Upgrade Tarantino at any time by executing `tt upgrade`.

```
cd $(mktemp -d)
git clone git@github.com:meet-tarantino/tarantino.git .
sudo make install
```

_NOTE:_ You don't have to clone everything if you don't want to.

## Usage

Invoke Tarantino by executing the `tt` command. Executing `tt` without any parameters will display usage information.

### Preparing a machine for 360 platform development

Once Tarantino is installed, let him clone all of the required source code repositories:

    tt clone

Next, you'll want Tarantino to create VMs for mongo, redis, rabbitmq and the 360 services. Go grab yourself a coffee since the one-time downloads will take a while.

    tt create

### Day-to-day operation

As you work on your services, you'll continue to write unit and integration tests within the service's git repository. As usual, execute the tests using `npm test`. When you're ready for the service at hand to play with others, run `tt recreate` to tear-down and recreate the entire environment.

## Maintainers

  + Mario Pareja
  + Darren McElligott 
