
################################################################################
node base {

	# requires the following puppet modules:
	# git
	# timezone
	# ntp

	# create default user, me, 
	git::config { 'user.name':
	  value => 'Chris Jefferies',
	}
	git::config { 'user.email':
	  value => 'chris@tinajalabs.com',
	}

	class { 'timezone':
	    timezone => 'America/Los_Angeles',
	}

	class { '::ntp':
	  servers => [ '0.us.pool.ntp.org', '1.us.pool.ntp.org', '2.us.pool.ntp.org', '3.us.pool.ntp.org' ],
	}
}


################################################################################
node 'tinaja1' inherits base 
{

	# requires the following puppet modules:
	# mysql
	# apache
	# php
	# graphite
	# nodejs
	# nodered
	# rabbitmq
	# mosquitto


	# just to test that a file can be written
	file { "/tmp/puppet-devbox.txt": 
		content => "created from node devbox..."
	}

	# set up the tinaja dirs
	file { ["/opt", "/opt/tinaja/",]:
	    ensure => "directory",
	    owner  => "root",
	    group  => "root",
	    mode   => 755,
	}

	# add some files into the tinaja dir
	file { "/opt/tinaja/js":
	    ensure => directory,
	    recurse => remote,
	    owner  => "root",
	    group  => "root",
	    mode   => 755,
	    source  => 'puppet:///modules/tinaja/js',
	}

	# install MySQL
	class { '::mysql::server':
		root_password           => 'ergot',
		remove_default_accounts => true,
		override_options        => $override_options
	}

	# install Apache2
	class { 'apache':
	  mpm_module => 'prefork',
	  default_vhost => true,
	}

	# set up php and mod_php in Apache
	class {'::php':}
	class {'::apache::mod::php': }

	# test vhost
	apache::vhost { 'info':
	  port    => '81',
	  docroot => '/var/www/info',
	}

	# create directories for graphite
	file { ["/opt/graphite","/opt/graphite/webapp","/opt/graphite/conf"]:
	    ensure => "directory",
	    owner  => "root",
	    group  => "root",
	    mode   => 755,
	}

	# graphite web setup
	apache::vhost { 'graphite':
	  port    => '8081',
	  docroot => '/opt/graphite/webapp',
	  wsgi_application_group      => '%{GLOBAL}',
	  wsgi_daemon_process         => 'graphite',
	  wsgi_daemon_process_options => {
	    processes          => '5',
	    threads            => '5',
	    display-name       => '%{GROUP}',
	    inactivity-timeout => '120',
	  },
	  wsgi_import_script          => '/opt/graphite/conf/graphite.wsgi',
	  wsgi_import_script_options  => {
	    process-group     => 'graphite',
	    application-group => '%{GLOBAL}'
	  },
	  wsgi_process_group          => 'graphite',
	  wsgi_script_aliases         => {
	    '/' => '/opt/graphite/conf/graphite.wsgi'
	  },
	  headers => [
	    'set Access-Control-Allow-Origin "*"',
	    'set Access-Control-Allow-Methods "GET, OPTIONS, POST"',
	    'set Access-Control-Allow-Headers "origin, authorization, accept"',
	  ],
	  directories => [{
	    path => '/media/',
	    order => 'deny,allow',
	    allow => 'from all'}
	  ]
	}->

	# graphite configuration, gets set up prior to apache
	class { 'graphite':
		gr_web_server => 'none',
		gr_django_1_4_or_less => false,
		gr_carbon_ver => '0.9.13',
		gr_whisper_ver => '0.9.13',
		gr_graphite_ver => '0.9.13',
		gr_django_db_user => 'tinaja',
		gr_django_db_password => 'tinaja',
		gr_enable_carbon_aggregator => false,

		gr_max_updates_per_second => 200,
		gr_timezone               => 'America/Los_Angeles',
		secret_key                => 'forthetimestheyareachangin',
		gr_storage_schemas        => [
        {
			name       => 'carbon',
			pattern    => '^carbon\.',
			retentions => '1m:90d'
        },
        {
			name       => 'tinajalabs',
			pattern    => 'tinaja',
			retentions => '10s:7d,1m:30d,1h:365d'
        },
        {
			name       => 'default',
			pattern    => '.*',
			retentions => '60:43200,900:350400'
        }
      ]
	}

	# install nodejs and npm
	class { 'nodejs':
		repo_url_suffix => 'node_0.12',
	}
	package { 'express':
		ensure   => 'present',
		provider => 'npm',
	}
	package { 'node-gyp':
		ensure   => 'present',
		provider => 'npm',
	}
	# this is for nodejs apps that access rabbitmq
	package { 'amqplib':
		ensure   => 'present',
		provider => 'npm',
	}

	class { 'nodered':
    	# user => 'tinaja',
    	# password => 'tinaja',
	}


	# add rabbitmq for message queuing
	class { '::rabbitmq':
		# add new users
		default_user => "admin",
		default_pass => "admin",
		
		delete_guest_user => false,

		# we need this to allow ipv4 access
		# gets added to rabbitmq-env.conf
		node_ip_address => "0.0.0.0",
	}


	class { 'mosquitto':}
}

