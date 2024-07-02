# Puppet manifest to install and configure Nginx

# Ensure Nginx package is installed
package { 'nginx':
  ensure => 'present',
}

# Update package list and install Nginx
exec { 'update-nginx':
  command => '/usr/bin/apt-get update',
  path    => '/usr/bin',
  require => Package['nginx'],
}

exec { 'install-nginx':
  command => '/usr/bin/apt-get -y install nginx',
  path    => '/usr/bin',
  require => Exec['update-nginx'],
}

# Create index.html with "Hello World!"
file { '/var/www/html/index.html':
  ensure  => 'present',
  content => 'Hello World!',
  owner   => 'www-data',
  group   => 'www-data',
  mode    => '0644',
}

# Configure Nginx to redirect /redirect_me
file { '/etc/nginx/sites-available/default':
  ensure  => 'present',
  content => "
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;
    index index.html index.htm index.nginx-debian.html;

    server_name _;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location /redirect_me {
        return 301 https://blog.ehoneahobed.com/;
    }
}
",
  notify => Exec['nginx-reload'],
}

# Ensure Nginx service is running and reload on config change
service { 'nginx':
  ensure    => 'running',
  enable    => true,
  hasstatus => true,
  hasrestart => true,
  subscribe => File['/etc/nginx/sites-available/default'],
}

# Notify Nginx service to reload upon configuration change
exec { 'nginx-reload':
  command     => '/usr/sbin/service nginx reload',
  refreshonly => true,
}

