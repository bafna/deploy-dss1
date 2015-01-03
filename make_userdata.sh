#!/bin/bash -xe
#Generates userdata.txt to be run on the machines 
cat <<EOF >userdata.txt
#!/bin/bash
date
set -x
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export layout=full
export git_protocol=https 
release="\$(lsb_release -cs)"
sudo mkdir -p /etc/facter/facts.d
export no_proxy="127.0.0.1,169.254.169.254,localhost,consul,jiocloud.com"
echo no_proxy="'127.0.0.1,169.254.169.254,localhost,consul,jiocloud.com'" >> /etc/environment
echo http_proxy="'${http_proxy}'" >> /etc/environment
echo https_proxy="'${https_proxy}'" >> /etc/environment
apt-get update
apt-get install -y hiera puppet software-properties-common 
wget -O puppet.deb -t 5 -T 30 http://apt.puppetlabs.com/puppetlabs-release-\${release}.deb
wget -O jiocloud.deb -t 5 -T 30 http://apt.overcastcloud.com/bafnag/bafnag/pool/main/p/python-jiocloud/python-jiocloud_0.1+1_all.deb 
wget -O puppet-jiocloud_0.9+14_all.deb -t 5 -T 30 http://apt.overcastcloud.com/bafnag/bafnag/pool/main/p/puppet-jiocloud/puppet-jiocloud_0.9+14_all.deb 
dpkg -i  puppet.deb puppet-jiocloud_0.9+14_all.deb jiocloud.deb 
apt-get  install -y -f
dpkg -i  puppet.deb puppet-jiocloud_0.9+14_all.deb jiocloud.deb 
time gem install faraday faraday_middleware --no-ri --no-rdoc;
time gem install librarian-puppet-simple --no-ri --no-rdoc;

echo 'consul_discovery_token='${consul_discovery_token} > /etc/facter/facts.d/consul.txt
# default to first 16 bytes of discovery token
echo 'consul_gossip_encrypt'=`echo ${consul_discovery_token} | cut -b 1-15 | base64` >> /etc/facter/facts.d/consul.txt
#echo 'current_version='${BUILD_NUMBER} > /etc/facter/facts.d/current_version.txt
echo 'env=staging'> /etc/facter/facts.d/env.txt



while true
do
  # first install all packages to make the build as fast as possible
  puppet apply --detailed-exitcodes /etc/puppet/manifests/site.pp --config_version='echo packages' --tags package
  ret_code_package=\$?
  # now perform base config
  (echo 'File<| title == "/etc/consul" |> { purge => false }'; echo 'include rjil::jiocloud' ) | puppet apply --config_version='echo bootstrap' --detailed-exitcodes --debug /etc/puppet/manifests/site.pp
  ret_code_jio=\$?
  if [[ \$ret_code_jio = 1 || \$ret_code_jio = 4 || \$ret_code_jio = 6 || \$ret_code_package = 1 || \$ret_code_package = 4 || \$ret_code_package = 6 ]]
  then
    echo "Puppet failed. Will retry in 5 seconds"
    sleep 5
  else
    break
  fi
done
date
EOF
