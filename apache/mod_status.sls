{% from "apache/map.jinja" import apache with context %}

{% if grains['os_family']=="FreeBSD" %}

include:
  - apache

{{ apache.confdir }}/httpd-info.conf:
  file.managed:
    - source:
      - salt://apache/files/{{ salt['grains.get']('os_family') }}/mod_status.conf.jinja
    - mode: 644
    - template: jinja
    - require:
      - pkg: apache

# Uncomment inclusion in configfile
sed -i -e 's,\(^#\)\(\s*Include.etc/apache24/extra/httpd-info.conf\),\2,g' {{ apache.configfile }}:
  cmd.run:
    - unless: grep -q "[[:space:]]Include.etc/apache24/extra/httpd-info.conf" {{ apache.configfile }}
    - order: 225
    - require:
      - pkg: apache
      - {{ apache.configfile }}
    - watch_in:
      - module: apache-restart

{% endif %}
