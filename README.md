# dns_caching

This cookbook installs and configures dnsmasq for local DNS caching. It relies on Chef's [resolver cookbook](https://github.com/chef-cookbooks/resolver) to update /etc/resolv.conf on all systems except Ubuntu (which uses resolvconf.

## Requirements

### Platforms

* Ubuntu
* RHEL/CentOS

### Attributes

In order for the cookbook to run, resolver attributes must be set to define DNS nameservers and search domains:
```ruby
"resolver" => {
  "nameservers" => ["10.13.37.120", "10.13.37.40"],
  "search" => "int.example.org",
  "options" => {
    "timeout" => 2, "rotate" => nil
  }
}
```

See the [resolver cookbook](https://github.com/chef-cookbooks/resolver#attributes) for more details on the available attributes.

## Usage

Create resolver attributes to define DNS nameservers and search domains. The first DNS nameserver defined must be the loopback interface address, usually 127.0.0.1. Once the dns_caching cookbook is assigned to a node and the resolver attributes are defined, the default recipe will install dnsmasq and use the resolver cookbook to update /etc/resolv.conf.

On Ubuntu systems, the resolver cookbook is not used and dnsmasq is configured to ignore /etc/resolv.conf and other configuration files created by the resolvconf package. It will use its own configuration for nameserver definitions instead. The resolvconf service will automatically update /etc/resolv.conf to direct DNS requests to dnsmasq once the package is installed.
