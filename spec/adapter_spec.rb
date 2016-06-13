# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

require_relative 'spec_helper'

describe 'vcloud_nats_updater_microservice' do
  let!(:provider) { double('provider', foo: 'bar') }

  before do
    allow_any_instance_of(Object).to receive(:sleep)
    require_relative '../adapter'
  end

  describe '#update_nats' do
    let!(:data)   do
      { router_name: 'adria-vse',
        datacenter_name: 'r3-acidre',
        datacenter_username: 'acidre@r3-acidre',
        nat_rules: [],
        client_name: 'r3labs-development' }
    end
    let!(:datacenter)   { double('datacenter', router: router) }
    let!(:router)       { double('router', nat: nats, update_service: true) }
    let!(:nats)         { double('nats', purge_rules: true) }

    before do
      allow_any_instance_of(Provider).to receive(:initialize).and_return(true)
      allow_any_instance_of(Provider).to receive(:admin_router).and_return(router)
      allow_any_instance_of(Provider).to receive(:datacenter).and_return(datacenter)
    end

    it 'update a nat on vcloud' do
      expect(update_nat(data)).to eq 'nat.update.vcloud.done'
    end
  end
end
