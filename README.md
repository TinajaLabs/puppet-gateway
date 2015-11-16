## Puppet a Home Automation Gateway

# NOTE: First pass.  The site.pp code could be inserted into an existing site.pp.

## Overview

This is a piece of a site.pp file that can be used to puppet a home automation system on a stock distro of Raspian, Debian or Ubuntu on a Raspberry Pi, a Beaglebone Black, or an Odroid.  Every time I get a new device, I find it tedious to install all of the software from my previous system.  Here's an attempt to automate that process and end up with a new gateway that has the following packages.

## Packages

At the end it should install the following packages:

* Apache 2.4.7 
* mysql 5.5.44
* PHP 5.5.9 
* node 0.12.7
* npm 2.11.3
* node-RED
* graphite 0.9.13
* grafana 2.1.3 
* mochad 0.1.16  (this is for X-10 access)

## Puppet Modules

These modules need to be installed on the puppet master to support the code in the site.pp.

You can typically install these modules like this:

```puppet module install puppetlabs-apache```, or 
```puppet module install puppetlabs-nodejs --environment development```

You can search and look for newer versions at Puppet Forge: https://forge.puppetlabs.com/

* puppetlabs-apache (v1.6.0)
* dwerder-grafana (v1.2.0)
* dwerder-graphite (v5.14.0)
* mosquitto (???)
* puppetlabs-motd (v1.2.0)
* puppetlabs-mysql (v3.3.0)
* puppetlabs-ntp (v3.3.0)
* puppetlabs-rabbitmq (v5.2.3)
* reederz-nodered (v0.1.1)
* mayflower-php (v3.4.1)
* python (???)
* puppetlabs-nodejs (v0.8.0)


Obviously I'm new to puppet so if someone has a better implementation, I'm ready to try it.

