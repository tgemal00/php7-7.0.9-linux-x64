# encoding: utf-8
require 'spec_helper'
require 'fileutils'
require 'open-uri'

describe 'building a binary', :integration do
  context 'when php5 is specified' do
    before(:all) do
      @extensions_dir = Dir.mktmpdir(nil, './spec')
      extensions_file = File.join(@extensions_dir, 'php-extensions.yml')

      File.write(extensions_file, open(php_extensions_source('5')).read)
      run_binary_builder('php', '5.6.14', "--md5=ae625e0cfcfdacea3e7a70a075e47155 --php-extensions-file=#{extensions_file}")
      @binary_tarball_location = Dir.glob(File.join(Dir.pwd, 'php-5.6.14-linux-x64.tgz')).first
    end

    after(:all) do
      FileUtils.rm(@binary_tarball_location)
      FileUtils.rm_rf(@extensions_dir)
    end

    it 'builds the specified binary, tars it, and places it in your current working directory' do
      expect(File).to exist(@binary_tarball_location)

      php_version_cmd = %{./spec/assets/php-exerciser.sh 5.6.14 #{File.basename(@binary_tarball_location)} ./php/bin/php -r 'echo phpversion();'}

      output, status = run(php_version_cmd)

      expect(status).to be_success
      expect(output).to include('5.6.14')
    end

    it 'copies in *.so files for some of the compiled extensions' do
      expect(tar_contains_file('php/lib/librabbitmq.so.4')).to eq true
      expect(tar_contains_file('php/lib/libhiredis.so.0.13')).to eq true
      expect(tar_contains_file('php/lib/libc-client.so.2007e')).to eq true
      expect(tar_contains_file('php/lib/libmcrypt.so.4')).to eq true
      expect(tar_contains_file('php/lib/libaspell.so.15')).to eq true
      expect(tar_contains_file('php/lib/libpspell.so.15')).to eq true
      expect(tar_contains_file('php/lib/libmemcached.so.11')).to eq true
      expect(tar_contains_file('php/lib/libgearman.so.7')).to eq true
      expect(tar_contains_file('php/lib/libcassandra.so.2')).to eq true
      expect(tar_contains_file('php/lib/libuv.so.0.10')).to eq true
      expect(tar_contains_file('php/lib/libsybdb.so.5')).to eq true
      expect(tar_contains_file('php/lib/librdkafka.so.1')).to eq true

      expect(tar_contains_file('php/lib/php/extensions/*/apcu.so')).to eq true
      expect(tar_contains_file('php/lib/php/extensions/*/ioncube.so')).to eq true
      expect(tar_contains_file('php/lib/php/extensions/*/pdo_dblib.so')).to eq true
      expect(tar_contains_file('php/lib/php/extensions/*/phalcon.so')).to eq true
      expect(tar_contains_file('php/lib/php/extensions/*/phpiredis.so')).to eq true

      expect(tar_contains_file('php/lib/libGeoIP.so.1')).to eq true
      expect(tar_contains_file('php/lib/php/extensions/*/geoip.so')).to eq true
      expect(tar_contains_file('php/geoipdb/lib/geoip_downloader.rb')).to eq true
      expect(tar_contains_file('php/geoipdb/bin/download_geoip_db.rb')).to eq true
    end
  end
end
