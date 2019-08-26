#
#
#
define filebeat_deprecated::prospector (
  $ensure                = present,
  $paths                 = [],
  $exclude_files         = [],
  $encoding              = 'plain',
  $input_type            = 'log',
  $fields                = {},
  $fields_under_root     = false,
  $ignore_older          = undef,
  $close_older           = undef,
  $doc_type              = 'log',
  $scan_frequency        = '10s',
  $harvester_buffer_size = 16384,
  $tail_files            = false,
  $backoff               = '1s',
  $max_backoff           = '10s',
  $backoff_factor        = 2,
  $close_inactive        = '5m',
  $close_renamed         = false,
  $close_removed         = true,
  $close_eof             = false,
  $clean_inactive        = 0,
  $clean_removed         = true,
  $close_timeout         = 0,
  $force_close_files     = false,
  $include_lines         = [],
  $exclude_lines         = [],
  $max_bytes             = '10485760',
  $multiline             = {},
  $json                  = {},
  $tags                  = [],
  $symlinks              = false,
) {

  validate_hash($fields, $multiline, $json)
  validate_array($paths, $exclude_files, $include_lines, $exclude_lines, $tags)
  validate_bool($tail_files, $close_renamed, $close_removed, $close_eof, $clean_removed, $symlinks)

  $prospector_template = $filebeat_deprecated::real_version ? {
    '1'     => 'prospector1.yml.erb',
    default => 'prospector5.yml.erb',
  }

  case $::kernel {
    'Linux' : {
      $filebeat_path = $filebeat_deprecated::real_version ? {
        '1'     => '/usr/bin/filebeat',
        default => '/usr/share/filebeat/bin/filebeat',
      }

      file { "${filebeat_deprecated::config_dir}/${name}.yml":
        ensure       => $ensure,
        owner        => 'root',
        group        => 'root',
        mode         => $::filebeat_deprecated::config_file_mode,
        content      => template("${module_name}/${prospector_template}"),
        validate_cmd => "${filebeat_path} -N -configtest -c %",
        notify       => Service['filebeat'],
      }
    }
    'Windows' : {
      $filebeat_path = 'c:\Program Files\Filebeat\filebeat.exe'

      file { "${filebeat_deprecated::config_dir}/${name}.yml":
        ensure       => $ensure,
        content      => template("${module_name}/${prospector_template}"),
        validate_cmd => "\"${filebeat_path}\" -N -configtest -c \"%\"",
        notify       => Service['filebeat'],
      }
    }
    default : {
      fail($filebeat_deprecated::kernel_fail_message)
    }
  }
}
