#
# == Define: s3cmd::backup
#
# Schedule a S3 bucket using s3cmd and cron
# 
# This define depends on the 'localbackups' class. Also, the 's3cmd' class has 
# to be included or this define won't be found.
#
# == Parameters
#
# [*title*]
#   The resource title defines the name of the bucket to backup.
# [*ensure*]
#   Status of the backup job. Either 'present' or 'absent'. Defaults to 
#   'present'.
# [*output_dir*]
#   The base directory for the backups. Defaults to 
#   $::s3cmd::config::backup_dir.
# [*hour*]
#   Hour(s) when s3cmd gets run. Defaults to 01.
# [*minute*]
#   Minute(s) when s3cmd gets run. Defaults to 17.
# [*weekday*]
#   Weekday(s) when s3cmd gets run. Defaults to * (all weekdays).
# [*report_only_errors*]
#   Suppress all cron output except errors. This is useful for reducing the
#   amount of emails cron sends. Valid values are true (default) and false.
# [*email*]
#   Email address where notifications are sent. Defaults to top-scope variable
#   $::servermonitor.
#
# == Examples
#
# s3cmd::backup { 'mybucket':
#   hour => '7',
#   minute => '5',
# }
#
define s3cmd::backup
(
    $ensure = 'present',
    $output_dir = $::s3cmd::config::backup_dir,
    $hour = '01',
    $minute = '17',
    $weekday = '*',
    $report_only_errors = true,
    $email = $::servermonitor
)
{

    include ::s3cmd
    include ::s3cmd::params

    # Make sure a subdirectory exists for this bucket
    file { "s3cmd-backup-${title}-dir":
        ensure  => directory,
        name    => "${output_dir}/${title}",
        owner   => $::os::params::adminuser,
        group   => $::os::params::admingroup,
        mode    => '0750',
        require => Class['s3cmd::config'],
    }

    # Even non-error output goes into stderr, so a grep is necessary
    if $report_only_errors {
        $cron_command = "/usr/bin/s3cmd sync s3://${title} ${output_dir}/${title} 2>&1|grep ERROR"
    } else {
        $cron_command = "/usr/bin/s3cmd sync s3://${title} ${output_dir}/${title}"
    }

    # Several other modules will attempt ensure that this same directory exists
    ensure_resource('file', $output_dir, { 'ensure' => 'directory' })

    cron { "s3cmd-backup-${title}-cron":
        ensure      => $ensure,
        command     => $cron_command,
        user        => root,
        hour        => $hour,
        minute      => $minute,
        weekday     => $weekday,
        environment => "MAILTO=${email}",
        require     => [ File[$output_dir], File["s3cmd-backup-${title}-dir"] ],
    }
}
