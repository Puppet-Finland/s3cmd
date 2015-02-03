#
# == Class: s3cmd
#
# This s3cmd class installs and configures s3cmd - a tool for managing Amazon 
# S3. The s3cmd tool does not have a global configuration file, so the current 
# approach is to configure it for the root user. Adding support for configuring 
# s3cmd for other, non-root users would make things slightly more complex.
#
# == Parameters
#
# [*access_key*]
#   S3 access key to use
# [*secret_key*]
#   S3 secret key to use
# [*use_https*]
#   Whether to use https. Valid values 'True' and 'False'. Defaults to 'True'.
# [*gpg_passphrase*]
#   GPG passphrase to use. Leave empty to not use encryption at all.
# [*backup_dir*]
#   The base directory for automated S3 backups. Defaults to 
#   '/var/backups/local/s3cmd'.
# [*backups*]
#   A hash of s3cmd::backup resources to realize.
#
# == Examples
#
# class { 's3cmd':
#   access_key => 'myaccesskey',
#   secret_key => 'mysecretkey',
#   gpg_passphrase => 'mygpgpassphrase',
# }
#
# == Authors
#
# Samuli Seppänen <samuli@openvpn.net>
#
# == License
#
# BSD-lisence
# See file LICENSE for details
#
class s3cmd
(
    $access_key,
    $secret_key,
    $use_https = 'True',
    $gpg_passphrase = '',
    $backup_dir = '/var/backups/local/s3cmd',
    $backups = {}
)
{

# Rationale for this is explained in init.pp of the sshd module
if hiera('manage_s3cmd', 'true') != 'false' {

    include s3cmd::install

    class { 's3cmd::config':
        access_key => $access_key,
        secret_key => $secret_key,
        use_https => $use_https,
        gpg_passphrase => $gpg_passphrase,
        backup_dir => $backup_dir,
    }

    # Realize the defined backup jobs
    create_resources('s3cmd::backup', $backups)
}
}
