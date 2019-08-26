#
#
#
class filebeat_deprecated::service {
  service { 'filebeat':
    ensure   => $filebeat_deprecated::real_service_ensure,
    enable   => $filebeat_deprecated::service_enable,
    provider => $filebeat_deprecated::service_provider,
  }
}
