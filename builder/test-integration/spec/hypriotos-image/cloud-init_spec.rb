require 'spec_helper'

describe package('cloud-init') do
  it { should be_installed }
end

describe command('dpkg -l cloud-init') do
  its(:stdout) { should match /ii  cloud-init/ }
  its(:exit_status) { should eq 0 }
end
