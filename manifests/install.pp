#
#
#
class filebeat_deprecated::install {
  anchor { 'filebeat_deprecated::install::begin': }

  case $::kernel {
    'Linux':   {
      class{ '::filebeat_deprecated::install::linux':
        notify => Class['filebeat_deprecated::service'],
      }
      Anchor['filebeat_deprecated::install::begin'] -> Class['filebeat_deprecated::install::linux'] -> Anchor['filebeat_deprecated::install::end']
      if $::filebeat_deprecated::manage_repo {
        class { '::filebeat_deprecated::repo': }
        Class['filebeat_deprecated::repo'] -> Class['filebeat_deprecated::install::linux']
      }
    }
    'Windows': {
      class{'::filebeat_deprecated::install::windows':
        notify => Class['filebeat_deprecated::service'],
      }
      Anchor['filebeat_deprecated::install::begin'] -> Class['filebeat_deprecated::install::windows'] -> Anchor['filebeat_deprecated::install::end']
    }
    default:   {
      fail($filebeat_deprecated::kernel_fail_message)
    }
  }

  anchor { 'filebeat_deprecated::install::end': }
}
