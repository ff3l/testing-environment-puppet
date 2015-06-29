class ssh{
        package { "openssh-server":
                 ensure => latest,
        }
        file { "/etc/ssh/sshd_config":
                owner   => root,
                group   => root,
                mode    => 644,
                source  => "puppet:///ssh/sshd_config",
        }
        service { ssh:
                ensure          => running,
                hasrestart      => true,
                subscribe       => File["/etc/ssh/sshd_config"],
        }
        file { "/home/credativ/.ssh":
                path    => "/home/credativ/.ssh",
                owner   => "credativ",
                group   => "credativ",
                mode    => 600,
                recurse => true,
                source  => "puppet:///ssh/ssh",
                ensure  => [directory, present],
        }
}
