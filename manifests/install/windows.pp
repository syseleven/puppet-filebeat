#
#
#
class filebeat_deprecated::install::windows {
  $filename = regsubst($filebeat_deprecated::download_url, '^https?.*\/([^\/]+)\.[^.].*', '\1')
  $foldername = 'Filebeat'

  file { $filebeat_deprecated::install_dir:
    ensure => directory,
  }

  remote_file { "${filebeat_deprecated::tmp_dir}/${filename}.zip":
    ensure      => present,
    source      => $filebeat_deprecated::download_url,
    verify_peer => false,
    proxy       => $filebeat_deprecated::proxy_address,
  }

  exec { "unzip ${filename}":
    command  => "\$sh=New-Object -COM Shell.Application;\$sh.namespace((Convert-Path '${filebeat_deprecated::install_dir}')).Copyhere(\$sh.namespace((Convert-Path '${filebeat_deprecated::tmp_dir}/${filename}.zip')).items(), 16)",
    creates  => "${filebeat_deprecated::install_dir}/Filebeat",
    provider => powershell,
    require  => [
      File[$filebeat_deprecated::install_dir],
      Remote_file["${filebeat_deprecated::tmp_dir}/${filename}.zip"],
    ],
  }

  exec { 'rename folder':
    command  => "Rename-Item '${filebeat_deprecated::install_dir}/${filename}' Filebeat",
    creates  => "${filebeat_deprecated::install_dir}/Filebeat",
    provider => powershell,
    require  => Exec["unzip ${filename}"],
  }

  exec { "install ${filename}":
    cwd      => "${filebeat_deprecated::install_dir}/Filebeat",
    command  => './install-service-filebeat.ps1',
    onlyif   => 'if(Get-WmiObject -Class Win32_Service -Filter "Name=\'filebeat\'") { exit 1 } else {exit 0 }',
    provider =>  powershell,
    require  => Exec['rename folder'],
  }
}
