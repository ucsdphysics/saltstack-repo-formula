# Completely ignore non-RHEL based systems
{% if grains['os_family'] == 'RedHat' %}

# A lookup table for SaltStack GPG keys & RPM URLs for various RedHat releases
{% if grains['osmajorrelease'][0] == '5' %}
  {% set repo = {
    'key': 'https://repo.saltstack.com/yum/redhat/5/x86_64/latest/SALTSTACK-EL5-GPG-KEY.pub',
    'key_hash': 'sha256=5bdb1253e82ef2b416de3a7615d75a0147f92fd6b9f7e1d0ddd9be7b8645bbd7',
    'file': 'https://repo.saltstack.com/yum/redhat/5/x86_64/saltstack-rhel5.repo',
    'file_hash': 'sha256=42cf3bc7ae40ef5a395aae9fb4d71c2620d309fbf9642832f1388dac7903f531'
  } %}
{% elif grains['osmajorrelease'][0] == '6' %}
  {% set repo = {
    'key': 'https://repo.saltstack.com/yum/redhat/6/x86_64/latest/SALTSTACK-GPG-KEY.pub',
    'key_hash': 'sha256=2bdcf4c30cdfd672aacb9eeff4d78b5e0cf9d405b82b1645ad5a876ec8e5037a',
    'file': 'https://repo.saltstack.com/yum/redhat/6/x86_64/saltstack-rhel6.repo',
    'file_hash': 'sha256=f99c5e91a506496f03881096923b73a804ceaaa1ef9e4fc4068fd2237f151efe'
  } %}
{% elif grains['osmajorrelease'][0] == '7' %}
  {% set repo = {
    'key': 'https://repo.saltstack.com/yum/redhat/7/x86_64/latest/SALTSTACK-GPG-KEY.pub',
    'key_hash': 'sha256=2bdcf4c30cdfd672aacb9eeff4d78b5e0cf9d405b82b1645ad5a876ec8e5037a',
    'file': 'https://repo.saltstack.com/yum/redhat/7/x86_64/saltstack-rhel7.repo',
    'file_hash': 'sha256=f99c5e91a506496f03881096923b73a804ceaaa1ef9e4fc4068fd2237f151efe'
  } %}
{% elif grains['os'] == 'Amazon' and grains['osmajorrelease'] == '2014' %}
  {% set repo = {
    'key': 'https://repo.saltstack.com/yum/redhat/6/x86_64/latest/SALTSTACK-GPG-KEY.pub',
    'key_hash': 'sha256=2bdcf4c30cdfd672aacb9eeff4d78b5e0cf9d405b82b1645ad5a876ec8e5037a',
    'file': 'https://repo.saltstack.com/yum/redhat/6/x86_64/saltstack-rhel6.repo',
    'file_hash': 'sha256=f99c5e91a506496f03881096923b73a804ceaaa1ef9e4fc4068fd2237f151efe'
  } %}
{% elif grains['os'] == 'Amazon' and grains['osmajorrelease'] == '2015' %}
  {% set repo = {
    'key': 'https://repo.saltstack.com/yum/redhat/6/x86_64/latest/SALTSTACK-GPG-KEY.pub',
    'key_hash': 'sha256=2bdcf4c30cdfd672aacb9eeff4d78b5e0cf9d405b82b1645ad5a876ec8e5037a',
    'file': 'https://repo.saltstack.com/yum/redhat/6/x86_64/saltstack-rhel6.repo',
    'file_hash': 'sha256=f99c5e91a506496f03881096923b73a804ceaaa1ef9e4fc4068fd2237f151efe'
  } %}
{% endif %}


install_pubkey_saltstack-repo:
  file.managed:
    - name: /etc/pki/rpm-gpg/SALTSTACK-GPG-KEY
    - source: {{ salt['pillar.get']('saltstack-repo:pubkey', repo.key) }}
    - source_hash:  {{ salt['pillar.get']('saltstack-repo:pubkey_hash', repo.key_hash) }}


saltstack-repo_file:
  file.managed:
    - name: /etc/yum.repos.d/saltstack.repo
    - source: {{ salt['pillar.get']('saltstack-repo:repofile', repo.file) }}
    - source_hash:  {{ salt['pillar.get']('saltstack-repo:repofile_hash', repo.file_hash) }}
    - require:
      - file: install_pubkey_saltstack-repo

set_pubkey_saltstack-repo:
  file.replace:
    - append_if_not_found: True
    - name: /etc/yum.repos.d/saltstack.repo
    - pattern: '^gpgkey=.*'
    - repl: 'gpgkey=file:///etc/pki/rpm-gpg/SALTSTACK-GPG-KEY'
    - require:
      - file: saltstack-repo_file

set_gpg_saltstack-repo:
  file.replace:
    - append_if_not_found: True
    - name: /etc/yum.repos.d/saltstack.repo
    - pattern: 'gpgcheck=.*'
    - repl: 'gpgcheck=1'
    - require:
      - file: saltstack-repo_file

{% if salt['pillar.get']('saltstack-repo:disabled', False) %}
disable_saltstack-repo:
  pkgrepo.managed:
    - name: saltstack-repo
    - disabled: true
{% else %}
enable_saltstack-repo:
  pkgrepo.managed:
    - name: saltstack-repo
    - disabled: false
{% endif %}
{% endif %}
