# == Class opendaylight::install
#
# This class is called from opendaylight for install.
#
class opendaylight::install {
  if $opendaylight::install_method == 'rpm' {
    # Choose Yum URL based on OS (CentOS vs Fedora)
    $base_url = $::operatingsystem ? {
      'CentOS' => 'https://copr-be.cloud.fedoraproject.org/results/dfarrell07/OpenDaylight/epel-7-$basearch/',
      'Fedora' => 'https://copr-be.cloud.fedoraproject.org/results/dfarrell07/OpenDaylight/fedora-$releasever-$basearch/',
    }

    yumrepo { 'opendaylight':
      # 'ensure' isn't supported with Puppet <3.5
      # Seems to default to present, but docs don't say
      # https://docs.puppetlabs.com/references/3.4.0/type.html#yumrepo
      # https://docs.puppetlabs.com/references/3.5.0/type.html#yumrepo
      baseurl  => $base_url,
      descr    => 'OpenDaylight SDN controller',
      gpgcheck => 0,
      enabled  => 1,
      before   => Package['opendaylight'],
    }

    package { 'opendaylight':
      ensure  => present,
      require => Yumrepo['opendaylight'],
    }
  }
  elsif $opendaylight::install_method == 'tarball' {
    # Download and extract the ODL tarball
    archive { 'opendaylight-0.2.2':
      ensure           => present,
      url              => $opendaylight::tarball_url,
      target           => '/opt/',
      checksum         => false,
      # This discards top-level dir of extracted tarball
      # Required to get proper /opt/opendaylight-<version> path
      # Ideally, camptocamp/puppet-archive would support this. PR later?
      strip_components => 1,
    }

    # TODO: Download ODL systemd .service file and put in right location
    archive { 'opendaylight-systemd':
      ensure           => present,
      url              => $opendaylight::unitfile_url,
      target           => '/usr/lib/systemd/system/',
      root_dir         => '.',
      checksum         => false,
      # This discards top-level dir of extracted tarball
      # Required to get proper /opt/opendaylight-<version> path
      # Ideally, camptocamp/puppet-archive would support this. PR later?
      strip_components => 1,
    }
  }
  else {
    fail("Unknown install method: ${opendaylight::install_method}")
  }
}
