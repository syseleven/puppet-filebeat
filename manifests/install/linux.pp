#
#
#
class filebeat_deprecated::install::linux {
  package { 'filebeat':
    ensure => $filebeat_deprecated::package_ensure,
  }
}
