require_relative '../../../kitchen/data/spec_helper'

describe 'apache.mod_remoteip' do

  case os[:family]
  when 'redhat'
    modremoteip_file = '/etc/httpd/conf.d/mod_remoteip.conf'
  when 'debian', 'ubuntu'
    modremoteip_file = '/etc/apache2/conf.d/mod_remoteip.conf'
  when 'freebsd'
    modremoteip_file = '/usr/local/etc/apache24/conf.d/mod_remoteip.conf'
  else
    # No other supported ATM
  end

  describe file(modremoteip_file) do
    it { should exist }
    it { should be_mode 644 }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    its(:content) { should match /RemoteIPHeader X-Forwarded-For/ }
    its(:content) { should match /RemoteIPTrustedProxy 127.0.0.1/ }
    its(:content) { should match /RemoteIPTrustedProxy 10.0.8.0\/24/ }
  end
end
