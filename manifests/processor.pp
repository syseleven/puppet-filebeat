#
#
#
define filebeat_deprecated::processor (
  $ensure         = present,
  $priority       = 10,
  $processor_name = $name,
  $params         = undef,
  $when           = undef,
) {
  include ::filebeat_deprecated

  validate_integer($priority)
  validate_string($processor_name)

  if versioncmp($filebeat_deprecated::real_version, '5') < 0 {
    fail('Processors only work on Filebeat 5.0 and higher')
  }

  if $priority < 10 {
    $_priority = "0${priority}"
  }
  else {
    $_priority = $priority
  }

  if $processor_name == 'drop_event' and $when == undef {
    fail('drop_event processors require a condition, without one ALL events are dropped')
  }
  elsif $processor_name != 'add_cloud_metadata' and $processor_name != 'add_locale' and $params == undef {
    fail("${processor_name} requires parameters to function as expected")
  }

  if $processor_name == 'add_cloud_metadata' {
    $_configuration = delete_undef_values(merge({'timeout' => '3s'}, $params))
  }
  elsif $processor_name == 'drop_event' {
    $_configuration = $when
  }
  else {
    $_configuration = delete_undef_values(merge({'when' => $when}, $params))
  }

  $processor_config = delete_undef_values({
    'processors' => [
      {
        "${processor_name}" => $_configuration
      },
    ],
  })

  case $::kernel {
    'Linux': {
      file{ "${filebeat_deprecated::config_dir}/${_priority}-processor-${name}.yml":
        ensure  => $ensure,
        owner   => 'root',
        group   => 'root',
        mode    => $::filebeat_deprecated::config_file_mode,
        content => inline_template('<%= @processor_config.to_yaml() %>'),
        notify  => Class['filebeat_deprecated::service'],
      }
    }
    'Windows': {
      file{ "${filebeat_deprecated::config_dir}/${_priority}-processor-${name}.yml":
        ensure  => $ensure,
        content => inline_template('<%= @processor_config.to_yaml() %>'),
        notify  => Class['filebeat_deprecated::service'],
      }
    }
    default: {
      fail($filebeat_deprecated::kernel_fail_message)
    }
  }
}
