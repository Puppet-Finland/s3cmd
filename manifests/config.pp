#
# == Class: s3cmd::config
#
# Configure s3cmd. For simplicity only configuring s3cmd for the root user is 
# supported.
#
class s3cmd::config
(
    $access_key,
    $secret_key,
    $use_https,
    $gpg_passphrase,
    $backup_dir

) inherits s3cmd::params
{

    # Activate client-side encryption if GPG passphrase is given
    if $gpg_passphrase {
        $encrypt = 'True'
    } else {
        $encrypt = 'False'
    }

    # Configure s3cmd
    file { 's3cmd-root-s3cfg':
        ensure  => present,
        name    => '/root/.s3cfg',
        content => template('s3cmd/s3cfg.erb'),
        owner   => $::os::params::adminuser,
        group   => $::os::params::admingroup,
        mode    => '0600',
        require => Class['s3cmd::install'],
    }

    # Make sure the backup directory exists
    file { 's3cmd-s3cmd':
        ensure => directory,
        name   => $backup_dir,
        owner  => root,
        group  => $::os::params::admingroup,
        mode   => '0750',
    }
}
