# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

require 'rubygems'
require 'bundler/setup'
require 'json'

require 'myst'

include Myst::Providers::VCloud

def update_nat(data)
  credentials = data[:datacenter_username].split('@')
  provider = Provider.new(endpoint:     data[:vcloud_url],
                          organisation: credentials.last,
                          username:     credentials.first,
                          password:     data[:datacenter_password])

  datacenter      = provider.datacenter(data[:datacenter_name])
  router          = datacenter.router(data[:router_name])

  nat = router.nat
  nat.purge_rules

  data[:rules].each do |rule|
    interface_ref = router.interface_network_reference(rule[:network])
    nat.add_rule(rule[:type],
                 { ip: rule[:origin_ip], port: rule[:origin_port] },
                 { ip: rule[:translation_ip], port: rule[:translation_port] },
                 rule[:protocol],
                 interface_ref)
  end

  router.update_service(nat)

  'nat.update.vcloud.done'
rescue => e
  puts e
  puts e.backtrace
  'nat.update.vcloud.error'
end

unless defined? @@test
  @data       = { id: SecureRandom.uuid, type: ARGV[0] }
  @data.merge! JSON.parse(ARGV[1], symbolize_names: true)
  original_stdout = $stdout
  $stdout = StringIO.new
  begin
    @data[:type] = update_nat(@data)
    if @data[:type].include? 'error'
      @data['error'] = { code: 0, message: $stdout.string.to_s }
    end
  ensure
    $stdout = original_stdout
  end

  puts @data.to_json
end
