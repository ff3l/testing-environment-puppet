class profiles::gateway (
    ) inherits profiles::base {

    package {'batctl':
        ensure => installed,
    }

    sysctl::value { "net.ipv4.ip_forward": value => "1"}
    sysctl::value { "net.ipv6.conf.all.forwarding": value => "1"}

    # inet6 kann man aktuell noch nicht anpassen, heisst müssen wir original repo clonen und in einem eigenen branch nötiges hinzufügen, anschliessend commiten
    # - address_family => inet6
    # - bridge-ports => none
    debnet::iface::bridge { 'br-ff3l-inet6':
        ifname => 'br-ff3l',
        address_family => inet6,
        bridge-ports => none,
        address => ,
        netmask => ,
    }

    debnet::iface::bridge { 'br-ff3l-inet':
        ifname => 'br-ff3l',
        address_family => inet,      
        address => ,
        netmask => ,
    }

    debnet::iface { 'bat0':
        method => 'manual',
        address_family => inet6,
        pre-ups => ['modprobe batman-adv', 'batctl gw server', 'batctl if add mesh-vpn'],
        ups => ['ip link set $IFACE up'],
        post-ups => ['brctl addif br-ff3l $IFACE', 'batctl it 10000', 'ip rule add from all fwmark 0x1 table 42'],
        pre-downs => ['brctl delif br-ff3l $IFACE || true'],
        downs => ['brctl delif br-ff3l $IFACE || true'],
    }


    ####
    # dnsmasq
    #
    # folgendes muss nochmal angeschaut werden:
    # bind-interfaces
    # except-interface=lo
    # log-facility=/var/log/dnsmasq.log

    class { 'dnsmasq':
        interface         => 'br-ff3l',
        listen_address    => '127.0.0.2',
        no_dhcp_interface => 'br-ff3l',
        domain_needed     => true,
        no_hosts          => true,
        no_resolv         => true,
        cache_size        => 4096,
        restart           => true,
    }

    dnsmasq::dnsserver { 'dns-local':
      ip => '127.0.0.1',
    }

    dnsmasq::dnsserver { 'dns-google':
      ip => '8.8.4.4',
    }

    dnsmasq::dnsserver { 'forward-lookup':
        ip => '127.0.0.1',
        domain => 'ff3l',
    }

    dnsmasq::dnsserver { 'reverse-lookup-1':
        ip => '127.0.0.1',
        domain => '119.10.in-addr.arpa',
    }

    dnsmasq::dnsserver { 'reverse-lookup-2':
        ip => '127.0.0.1',
        domain => '2.0.0.7.f.b.0.1.0.0.2.ip6.arpa',
    }
