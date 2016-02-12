template "#{node['mysql']['path']}/my.cnf" do
  source 'my.cnf.erb'
  variables({:port => '3306'})
end

service 'mysqld' do
  action :restart
end
