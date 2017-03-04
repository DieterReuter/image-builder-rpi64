require 'spec_helper'

describe file('/boot/device-init.yaml') do
  it { should_not be_file }
end

describe file('/usr/local/bin/device-init') do
  it { should_not be_file }
end
