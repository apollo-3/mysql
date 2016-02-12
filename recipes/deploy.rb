remote_file "#{node['tmp']}/world.sql.gz" do
  source node['sqldump']
end

bash "extract_dump" do
  cwd node['tmp']
  code <<-EOH
    gunzip -c world.sql.gz > world.sql
    echo 'nothing'
    EOH
  not_if {File.file? "#{node['tmp']}/world.sql"}
end

bash "import_dump" do
  cwd node['tmp']
  code <<-EOH
    #{node['mysql']['path']}/bin/mysql -uroot < "#{node['tmp']}/world.sql"
    EOH
  not_if {system("#{node['mysql']['path']}/bin/mysql -uroot -e 'SHOW DATABASES' | grep world")}
end
