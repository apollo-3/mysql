module Chef::Recipe::MySql
  module Helper
    def self.extract_tar_gz tar_gz, destination
      require 'fileutils'
      require 'rubygems/package'
      require 'zlib'    

      Gem::Package::TarReader.new(Zlib::GzipReader.open tar_gz) do |tar|
        tar.each do |entry|
          if entry.full_name == '././@LongLink'
            dest = File.join destination, entry.read.strip
          else
            dest = File.join destination, entry.full_name
          end
          dest = dest.gsub(/(.*?)(\/$)/,'\1')
#          puts dest
          if entry.directory?
            FileUtils.rm_rf dest unless File.directory? dest
            FileUtils.mkdir_p dest
          elsif entry.file?
            FileUtils.rm_rf dest unless File.file? dest
            File.open dest, "wb" do |f|
              f.print entry.read
            end
          end
        end
      end
    
    end
  end
end
