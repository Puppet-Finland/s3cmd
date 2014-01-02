#
# == Class: s3cmd::install
#
# Installs s3cmd package
#
class s3cmd::install {

    include s3cmd::params

    package { 's3cmd':
        name => "${::s3cmd::params::package_name}",
        ensure => installed,
    }
}
