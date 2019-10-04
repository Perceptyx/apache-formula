{% from "apache/map.jinja" import apache with context %}

{% if grains['os_family']=="Debian" %}

include:
  - apache

a2enmod mod_remoteip:
  cmd.run:
    - name: a2enmod remoteip
    - unless: ls /etc/apache2/mods-enabled/remoteip.load
    - order: 255
    - require:
      - pkg: apache
    - watch_in:
      - module: apache-restart

/etc/apache2/conf-available/remoteip.conf:
  file.managed:
    - template: jinja
    - source:
      - salt://apache/files/{{ salt['grains.get']('os_family') }}/conf-available/remoteip.conf.jinja
    - require:
      - pkg: apache
    - watch_in:
      - service: apache

a2enconf remoteip:
  cmd.run:
    - unless: ls /etc/apache2/conf-enabled/remoteip.conf
    - order: 255
    - require:
      - pkg: apache
    - watch_in:
      - module: apache-reload

{% elif grains['os_family']=="RedHat" %}

include:
  - apache

/etc/httpd/conf.d/remoteip.conf:
  file.managed:
    - template: jinja
    - source:
      - salt://apache/files/{{ salt['grains.get']('os_family') }}/remoteip.conf.jinja
    - require:
      - pkg: apache
    - watch_in:
      - service: apache

{% elif grains['os_family']=="FreeBSD" %}

include:
  - apache

{{ apache.modulesdir }}/050_mod_remoteip.conf:
  file.managed:
    - source:
      - salt://apache/files/{{ salt['grains.get']('os_family') }}/mod_remoteip.conf.jinja
    - mode: 644
    - template: jinja
    - require:
      - pkg: apache
    - watch_in:
      - module: apache-restart

{% endif %}
