#
# Cookbook Name:: mysql
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

# Setting epel repository
cookbook_file '/etc/yum.repos.d/epel.repo' do
  source 'epel.repo'
end

# Installing necessary packages
['cmake', 'gcc-c++', 'perl-Data-Dumper', 'zlib', 'bzip2-devel', 'bison', 'python-devel', 'boost', 'boost-devel'].each do |pkg|
  yum_package "#{pkg}"
end

# Downloading mysql archive
remote_file "#{node['tmp']}/mysql.tar.gz" do
  source node['mysql']['url']
  action :create
end

# Extracting mysql archive
ruby_block "#{node['tmp']}/mysql.tar.gz" do
  block do
    MySql::Helper::extract_tar_gz "#{node['tmp']}/mysql.tar.gz", node['tmp']
  end
  not_if {File.directory? "#{node['tmp']}/#{node['mysql']['version']}"}
end

# If mysql is the latest then boost library is needed
if node['mysql']['version']=='5.7.11'
  remote_file "#{node['tmp']}/boost.tar.gz" do
    source node['boost']['url']
    action :create
    notifies :action, "ruby_block[#{node['tmp']}/boost.tar.gz]", :immediately
  end
end

# Extracting boost archive if it's necessary
ruby_block "#{node['tmp']}/boost.tar.gz" do
  block do
    MySql::Helper.extract_tar_gz "#{node['tmp']}/boost.tar.gz", '/usr/local/'
  end
  not_if {File.directory? "/usr/local/#{node['boost']['version']}"}
  action :nothing
  notifies :action, 'bash[install_boost]', :immediately
end

# Building and installing boost if it's necessary
bash "install_boost" do
  cwd "/usr/local/#{node['boost']['version']}"
  code <<-EOH
    chmod -R 755 ./*
    ./bootstrap.sh
    ./b2 install
    EOH
  not_if {File.file? "/usr/local/#{node['boost']['version']}/b2"}
  action :nothing
end

# Adding mysql user
user node['mysql']['user']

# Creating mysql directory
directory "#{node['mysql']['path']}"

# Buidling and installing mysql server
bash "install_mysql" do
  cwd "#{node['tmp']}/#{node['mysql']['version']}"
  code <<-EOH
    cmake -DCMAKE_INSTALL_PREFIX="#{node['mysql']['path']}" .
    make
    make install
    [[ `grep -c mysql #node{'mysql']['user']}/.bashrc` -eq 0 ]] && echo "PATH=$PATH:#{node['mysql']['path']}/bin" >> /home/#{node['mysql']['user']}/.bashrc
    cd "#{node['mysql']['path']}"
    scripts/mysql_install_db
    chown -R "#{node['mysql']['user']}" "#{node['mysql']['path']}"
    EOH
  not_if {File.directory? "{#node['mysql']['path']}"}
end

# Installing systemd service
template "/etc/systemd/system/mysqld.service" do
  source 'mysqld.service.erb'
  variables({:user => node['mysql']['user'], :path => node['mysql']['path']})
end

# Adding sudo privileges to a user
template "/etc/sudoers.d/#{node['mysql']['user']}" do
  source 'sudo.erb'
  variables({:user => node['mysql']['user']})
  mode '0440'
end

# Making mysqld service autosart at boot
service 'mysqld' do
  action :enable
end

# Ensure mysqld service is running
service 'mysqld' do
  action :start
end
