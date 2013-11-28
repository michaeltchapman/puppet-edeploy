#
# Copyright (C) 2013 eNovance SAS <licensing@enovance.com>
#
# Author: Yanis Guenane <yanis.guenane@enovance.com>
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.

# == Class: edeploy::prerequisites
#
# Role class to process the prerequisite for eDeploy
#
# === Parameters
#
# [*address*]
#   Refer to Class['edeploy']
#
# [*tftproot*]
#   (boolean) Enable access log
#
# [*serv*]
#   Refer to Class['edeploy']
#
# [*rserv*]
#   Refer to Class['edeploy']
#
# [*rserv_port*]
#   Refer to Class['edeploy']
#
# [*hserv*]
#   Refer to Class['edeploy']
#
# [*hserv_port*]
#   Refer to Class['edeploy']
#
# [*onfailure*]
#   Refer to Class['edeploy']
#
# [*onsuccess*]
#   Refer to Class['edeploy']
#
# [*verbose*]
#   Refer to Class['edeploy']
#
# [*upload_log*]
#   Refer to Class['edeploy']
#
# [*http_path*]
#   Refer to Class['edeploy']
#
# [*http_port*]
#   Refer to Class['edeploy']
#
# [*rsync_exports*]
#   Refer to Class['edeploy']
#
# [*rsync_max_connections*]
#   Refer to Class['edeploy']
#
# [*webserver_docroot*]
#   Refer to Class['edeploy']
#
# [*webserver_port*]
#   Refer to Class['edeploy']
#
class edeploy::prerequisites (
    $address,
    $tftproot,
    $serv,
    $rserv,
    $rserv_port,
    $hserv,
    $hserv_port,
    $onfailure,
    $onsuccess,
    $verbose,
    $upload_log,
    $http_path,
    $http_port,
    $rsync_exports,
    $rsync_max_connections,
    $webserver_docroot,
    $webserver_port
) {

  require devtools
  include edeploy::params

  package {$edeploy::params::packages :
    ensure => installed,
  }
  # NOTE (spredzy) : Wheezy profile is missing in RHEL 6.4 debootstrap package
  #                  It's being create here. A request upstream might be done.
  if $::osfamily == 'RedHat' {
    file {'/usr/share/debootstrap/scripts/wheezy' :
      ensure  => 'link',
      target  => '/usr/share/debootstrap/scripts/sid',
      require => Package[$edeploy::params::packages],
    }
  }

  class {'edeploy::tftpserver' :
    address    => $address,
    directory  => $tftproot,
    serv       => $serv,
    rserv      => $rserv,
    rserv_port => $rserv_port,
    hserv      => $hserv,
    hserv_port => $hserv_port,
    onfailure  => $onfailure,
    onsuccess  => $onsuccess,
    verbose    => $verbose,
    upload_log => $upload_log,
    http_path  => $http_path,
    http_port  => $http_port,
    require    => Package[$edeploy::params::packages],
  }
  class {'edeploy::rsyncserver' :
    exports         => $rsync_exports,
    max_connections => $rsync_max_connections,
    address         => $address,
    require         => Class['edeploy::tftpserver'],
  } ->
  class {'edeploy::webserver' :
    docroot => $webserver_docroot,
    port    => $webserver_port,
    require => Class['edeploy::rsyncserver'],
  }

}