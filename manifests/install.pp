#
# == Class: s3cmd::install
#
# Installs s3cmd package
#
class s3cmd::install inherits s3cmd::params {

    package { 's3cmd':
        ensure => installed,
        name   => $::s3cmd::params::package_name,
    }
}
