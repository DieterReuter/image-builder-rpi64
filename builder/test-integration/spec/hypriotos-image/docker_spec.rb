require 'spec_helper'

describe package('docker-ce') do
  it { should be_installed }
end

describe command('dpkg -l docker-ce') do
  its(:stdout) { should match /ii  docker-ce/ }
  its(:stdout) { should match /5:18.09.7~3-0~debian/ }
  its(:stdout) { should match /arm64/ }
  its(:exit_status) { should eq 0 }
end

describe command('dpkg -l docker-ce-cli') do
  its(:stdout) { should match /ii  docker-ce-cli/ }
  its(:stdout) { should match /5:18.09.7~3-0~debian/ }
  its(:stdout) { should match /arm64/ }
  its(:exit_status) { should eq 0 }
end

describe command('dpkg -l containerd.io') do
  its(:stdout) { should match /ii  containerd.io/ }
  its(:stdout) { should match /1.2.6-3/ }
  its(:stdout) { should match /arm64/ }
  its(:exit_status) { should eq 0 }
end

describe file('/usr/bin/docker') do
  it { should be_file }
  it { should be_mode 755 }
  it { should be_owned_by 'root' }
end

describe file('/usr/bin/docker-init') do
  it { should be_file }
  it { should be_mode 755 }
  it { should be_owned_by 'root' }
end

describe file('/usr/bin/docker-proxy') do
  it { should be_file }
  it { should be_mode 755 }
  it { should be_owned_by 'root' }
end

describe file('/usr/bin/dockerd') do
  it { should be_file }
  it { should be_owned_by 'root' }
end

describe file('/usr/bin/dockerd-ce') do
  it { should be_file }
  it { should be_mode 755 }
  it { should be_owned_by 'root' }
end

describe file('/usr/bin/containerd') do
  it { should be_file }
  it { should be_mode 755 }
  it { should be_owned_by 'root' }
end

describe file('/usr/bin/containerd-shim') do
  it { should be_file }
  it { should be_mode 755 }
  it { should be_owned_by 'root' }
end

describe file('/lib/systemd/system/docker.socket') do
  it { should be_file }
  it { should be_mode 644 }
  it { should be_owned_by 'root' }
end

describe file('/var/run/docker.sock') do
  it { should be_socket }
  it { should be_mode 660 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'docker' }
end

describe file('/etc/default/docker') do
  it { should be_file }
  it { should be_mode 644 }
  it { should be_owned_by 'root' }
end

describe file('/var/lib/docker') do
  it { should be_directory }
  it { should be_mode 711 }
  it { should be_owned_by 'root' }
end

describe file('/var/lib/docker/overlay2') do
  it { should be_directory }
  it { should be_mode 700 }
  it { should be_owned_by 'root' }
end

describe command('docker -v') do
  its(:stdout) { should match /Docker version 18.09.7, build/ }
  its(:exit_status) { should eq 0 }
end

describe command('docker info') do
  its(:stdout) { should match /Storage Driver: overlay2/ }
  its(:exit_status) { should eq 0 }
end

describe interface('lo') do
  it { should exist }
end

describe interface('docker0') do
  it { should exist }
end

describe service('docker') do
  it { should be_enabled }
  it { should be_running }
end

describe command('grep docker /var/log/syslog') do
  its(:stdout) { should match /Daemon has completed initialization/ }
  its(:exit_status) { should eq 0 }
end
