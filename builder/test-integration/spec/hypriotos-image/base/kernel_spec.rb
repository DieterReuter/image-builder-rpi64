require 'spec_helper'

describe command('uname -r') do
  its(:stdout) { should match /4.14.37-hypriotos-v8/ }
  its(:exit_status) { should eq 0 }
end

describe file('/lib/modules/4.14.37-hypriotos-v8/kernel') do
  it { should be_directory }
end
