{% from "apache/map.jinja" import apache with context %}

{% if grains['os_family']=="Debian" %}
{% set mpm_module = salt['pillar.get']('apache:mpm:module', 'mpm_prefork') %}

include:
  - apache

a2enmod {{ mpm_module }}:
  cmd.run:
    - unless: ls /etc/apache2/mods-enabled/{{ mpm_module }}.load
    - require:
      - pkg: apache
    - watch_in:
      - module: apache-restart
  file.managed:
    - name: /etc/apache2/mods-available/{{ mpm_module }}.conf
    - template: jinja
    - source:
      - salt://apache/files/Debian/mpm/{{ mpm_module }}.conf.jinja
    - require:
      - pkg: apache
    - watch_in:
      - module: apache-restart

# Deactivate the other mpm modules as a previous step
{% for mod in ['mpm_prefork', 'mpm_worker', 'mpm_event'] if not mod == mpm_module %}
a2dismod {{ mod }}:
  cmd.run:
    - onlyif: test -e /etc/apache2/mods-enabled/{{ mod }}.load
    - require:
      - pkg: apache
    - require_in:
      - cmd: a2enmod {{ mpm_module }}
    - watch_in:
      - module: apache-restart
{% endfor %}

{% elif grains['os_family']=="FreeBSD" %}

#Include etc/apache24/extra/httpd-mpm.conf

# Uncomment inclusion in configfile
sed -i'.salt' -e 's,\(^#\)\(\s*Include.etc/apache24/extra/httpd-mpm.conf\),\2,g' {{ apache.configfile }}:
  cmd.run:
    - unless: grep -q "[[:space:]]Include.etc/apache24/extra/httpd-mpm.conf" {{ apache.configfile }}
    - order: 225
    - require:
      - pkg: apache
      - {{ apache.confdir }}/httpd-mpm.conf
      - {{ apache.configfile }}
    - watch_in:
      - module: apache-restart

{{ apache.confdir }}/httpd-mpm.conf:
  file.managed:
    - source: salt://apache/files/{{ salt['grains.get']('os_family') }}/mod_mpm.conf.jinja
    - mode: 644
    - template: jinja
    - require:
      - pkg: apache
    - watch_in:
      - module: apache-restart

{% endif %}
