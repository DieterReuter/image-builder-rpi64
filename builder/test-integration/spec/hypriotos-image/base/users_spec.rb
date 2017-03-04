describe user('root') do
  it { should exist }
  it { should have_home_directory '/root' }
  it { should have_login_shell '/bin/bash' }
end

describe group('docker') do
  it { should exist }
end

describe user('pirate') do
  it { should_not exist }
end

describe file('/etc/sudoers') do
  it { should be_file }
  it { should be_mode 440 }
  it { should be_owned_by 'root' }
end

describe file('/etc/sudoers.d') do
  it { should be_directory }
  it { should be_mode 750 }
  it { should be_owned_by 'root' }
end

describe file('/etc/sudoers.d/user-pirate') do
  it { should_not be_file }
end

describe file('/etc/sudoers.d/010_pi-nopasswd') do
  it { should_not be_file }
end

describe file('/root/.bashrc') do
  it { should be_file }
  it { should be_mode 644 }
  it { should be_owned_by 'root' }
end
describe file('/root/.bash_prompt') do
  it { should be_file }
  it { should be_mode 644 }
  it { should be_owned_by 'root' }
end

describe file('/home/pirate') do
  it { should_not be_directory }
end
