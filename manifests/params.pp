#
# == Class: s3cmd::params
#
# Defines some variables based on the operating system
#
class s3cmd::params {

    include ::os::params

    case $::osfamily {
        'Debian': {
            $package_name = 's3cmd'
        }
        default: {
            fail("Unsupported OS: ${::osfamily}")
        }
    }
}
