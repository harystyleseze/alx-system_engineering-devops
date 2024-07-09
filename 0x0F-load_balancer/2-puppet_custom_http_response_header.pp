# Use Puppet to automate the task of creating a custom HTTP header response

# Update package lists
exec { 'update':
  command => '/usr/bin/apt-get update',
  path    => '/usr/bin',
}

# Install Nginx
package { 'nginx':
  ensure => 'present',
}

# Manage Nginx configuration file
file { '/etc/nginx/nginx.conf':
  ensure  => 'file',
  content => template('nginx/nginx.conf.erb'),
  notify  => Exec['nginx-restart'],
}

# Add custom HTTP header to Nginx configuration
file_line { 'http_header':
  path  => '/etc/nginx/nginx.conf',
  line  => '    http {',
  after => 'http {',
  match => 'http {',
  content => "    add_header X-Served-By \"$hostname\";\n",
  notify  => Exec['nginx-restart'],
}

# Restart Nginx service
exec { 'nginx-restart':
  command     => '/usr/sbin/service nginx restart',
  refreshonly => true,
}

