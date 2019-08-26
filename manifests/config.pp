#
#
#
class filebeat_deprecated::config {
  $filebeat_config = delete_undef_values({
    'shutdown_timeout'  => $filebeat_deprecated::shutdown_timeout,
    'beat_name'         => $filebeat_deprecated::beat_name,
    'tags'              => $filebeat_deprecated::tags,
    'queue_size'        => $filebeat_deprecated::queue_size,
    'max_procs'         => $filebeat_deprecated::max_procs,
    'fields'            => $filebeat_deprecated::fields,
    'fields_under_root' => $filebeat_deprecated::fields_under_root,
    'filebeat'          => {
      'spool_size'       => $filebeat_deprecated::spool_size,
      'idle_timeout'     => $filebeat_deprecated::idle_timeout,
      'registry_file'    => $filebeat_deprecated::registry_file,
      'publish_async'    => $filebeat_deprecated::publish_async,
      'config_dir'       => $filebeat_deprecated::config_dir,
      'shutdown_timeout' => $filebeat_deprecated::shutdown_timeout,
    },
    'output'            => $filebeat_deprecated::outputs,
    'shipper'           => $filebeat_deprecated::shipper,
    'logging'           => $filebeat_deprecated::logging,
    'runoptions'        => $filebeat_deprecated::run_options,
    'processors'        => $filebeat_deprecated::processors,
  })

  Filebeat_deprecated::Prospector <| |> -> File[$filebeat_deprecated::config_file]

  case $::kernel {
    'Linux'   : {

      $filebeat_path = $filebeat_deprecated::real_version ? {
        '1'     => '/usr/bin/filebeat',
        default => '/usr/share/filebeat/bin/filebeat',
      }

      file { $filebeat_deprecated::config_file:
        ensure       => $filebeat_deprecated::file_ensure,
        content      => template($filebeat_deprecated::real_conf_template),
        owner        => 'root',
        group        => 'root',
        mode         => $filebeat_deprecated::config_file_mode,
        validate_cmd => "${filebeat_path} -N -configtest -c %",
        notify       => Service['filebeat'],
        require      => File[$filebeat_deprecated::config_dir],
      }

      file { $filebeat_deprecated::config_dir:
        ensure  => $filebeat_deprecated::directory_ensure,
        owner   => 'root',
        group   => 'root',
        mode    => $filebeat_deprecated::config_dir_mode,
        recurse => $filebeat_deprecated::purge_conf_dir,
        purge   => $filebeat_deprecated::purge_conf_dir,
        force   => true,
      }
    } # end Linux

    'Windows' : {
      $filebeat_path = 'c:\Program Files\Filebeat\filebeat.exe'

      file { $filebeat_deprecated::config_file:
        ensure       => $filebeat_deprecated::file_ensure,
        content      => template($filebeat_deprecated::real_conf_template),
        validate_cmd => "\"${filebeat_path}\" -N -configtest -c \"%\"",
        notify       => Service['filebeat'],
        require      => File[$filebeat_deprecated::config_dir],
      }

      file { $filebeat_deprecated::config_dir:
        ensure  => $filebeat_deprecated::directory_ensure,
        recurse => $filebeat_deprecated::purge_conf_dir,
        purge   => $filebeat_deprecated::purge_conf_dir,
        force   => true,
      }
    } # end Windows

    default : {
      fail($filebeat_deprecated::kernel_fail_message)
    }
  }
}
