# The Inspec reference, with examples and extensive documentation, can be
# found at https://docs.chef.io/inspec_reference.html

describe package('dnsmasq') do
  it { should be_installed }
end

describe service('dnsmasq') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end

if os[:family] == 'debian'
  describe file('/etc/resolv.conf') do
    it { should exist }
    its('content') { should match(%r{nameserver 127.0.0.1}) }
  end

  describe file('/etc/dnsmasq.d/dns_caching.conf') do
    it { should exist }
    its('content') { should match(%r{server=8.8.8.8}) }
  end
else
  describe file('/etc/resolv.conf') do
    it { should exist }
    its('content') { should match(%r{nameserver 127.0.0.1}) }
    its('content') { should match(%r{nameserver 8.8.8.8}) }
  end

  describe file('/etc/dnsmasq.d/dns_caching.conf') do
    it { should exist }
  end
end

describe command('host google.com') do
  its('stdout') { should match(/google.com has address/) }
  its('stdout') { should_not match(/NXDOMAIN/) }
end
