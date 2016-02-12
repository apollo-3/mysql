default['mysql']['url'] = 'http://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-5.6.29.tar.gz'
default['mysql']['version'] = default['mysql']['url'].match(/mysql-\d\.\d\.\d{1,2}/)
default['mysql']['user'] = 'mysql'
default['mysql']['path'] = "/usr/local/mysql"
default['boost']['url'] = 'http://netcologne.dl.sourceforge.net/project/boost/boost/1.59.0/boost_1_59_0.tar.gz'
default['boost']['version'] = default['boost']['url'].split('/').last.gsub('.tar.gz','')
default['tmp'] = '/tmp'
default['sqldump'] = 'http://downloads.mysql.com/docs/world.sql.gz'
