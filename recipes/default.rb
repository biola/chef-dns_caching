#
# Cookbook Name:: dns_caching
# Recipe:: default
#
# Copyright 2017, Biola University
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Requires resolver attributes to be set
if node['resolver']['nameservers'].empty? ||
   node['resolver']['nameservers'][0].empty?
  Chef::Log.warn("The ['resolver']['nameservers'] attribute is not set.")
  Chef::Log.warn('Exiting the recipe...')
  return
end

# For Ubuntu 12+ systems
if node['platform'] == 'ubuntu' && node['platform_version'].to_i >= 12
  # Pre-stage the dnsmasq configuration file and defaults file
  directory '/etc/dnsmasq.d' do
    owner 'root'
    group 'root'
    mode '0755'
  end

  template '/etc/dnsmasq.d/dns_caching.conf' do
    source 'dns_caching.conf.erb'
    owner 'root'
    group 'root'
    mode '0644'
    notifies :restart, 'service[dnsmasq]' if ::File.exist?('/etc/dnsmasq.conf')
  end

  template '/etc/default/dnsmasq' do
    source 'dnsmasq.erb'
    owner 'root'
    group 'root'
    mode '0644'
  end

  # Install dnsmasq package, keeping the pre-staged configuration files
  package 'dnsmasq' do
    options '-o Dpkg::Options::="--force-confdef" '\
      '-o Dpkg::Options::="--force-confold"'
    action :install
  end

  # Restart the dnsmasq service only if configuration changes were made
  service 'dnsmasq' do
    action :nothing
  end
# For all other platforms
else
  # Install dnsmasq package
  package 'dnsmasq'

  template '/etc/dnsmasq.conf' do
    source 'dnsmasq.conf.erb'
    owner 'root'
    group 'root'
    mode '0644'
    notifies :restart, 'service[dnsmasq]'
  end

  template '/etc/dnsmasq.d/dns_caching.conf' do
    source 'dns_caching.conf.erb'
    owner 'root'
    group 'root'
    mode '0644'
    notifies :restart, 'service[dnsmasq]'
  end

  # Restart the dnsmasq service only if configuration changes were made
  service 'dnsmasq' do
    action :nothing
  end

  # Use the resolver cookbook to update /etc/resolv.conf
  include_recipe 'resolver'
end
