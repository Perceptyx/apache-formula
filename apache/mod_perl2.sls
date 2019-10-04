{% from "apache/map.jinja" import apache with context %}

include:
  - apache

mod-perl2:
  pkg.installed:
    - name: {{ apache.mod_perl2 }}
    - order: 180
    - require:
      - pkg: apache

{% if grains['os_family']=="Debian" %}
a2enmod mod_{{ apache.mod_perl_name }}:
  cmd.run:
    - name: a2enmod {{ apache.mod_perl_name }}
    - unless: ls /etc/apache2/mods-enabled/{{ apache.mod_perl_name }}.load
    - order: 225
    - require:
      - pkg: mod-perl2
    - watch_in:
      - module: apache-restart
    - require_in:
      - module: apache-restart
      - module: apache-reload
      - service: apache

{{ apache.confdir }}/{{ apache.mod_perl_name }}.conf:
  file.managed:
    - source: salt://apache/files/{{ salt['grains.get']('os_family') }}/conf-available/perl.conf.jinja
    - mode: 644
    - template: jinja
    - require:
      - pkg: apache
    - watch_in:
      - module: apache-restart
    - require_in:
      - module: apache-restart
      - module: apache-reload
      - service: apache

a2enconf {{ apache.mod_perl_name }}:
  cmd.run:
    - unless: ls {{ apache.confdir }}/conf-enabled/{{ apache.mod_perl_name }}.conf
    - order: 255
    - require:
      - pkg: apache
      - file: {{ apache.confdir }}/{{ apache.mod_perl_name }}.conf
    - watch_in:
      - module: apache-reload
    - require_in:
      - module: apache-restart
      - module: apache-reload
      - service: apache
{% elif grains['os_family']=="FreeBSD" %}

{{ apache.modulesdir }}/260_mod_perl.conf:
  file.managed:
    - source: salt://apache/files/{{ salt['grains.get']('os_family') }}/mod_perl2.conf.jinja
    - mode: 644
    - template: jinja
    - require:
      - pkg: apache
    - watch_in:
      - module: apache-restart

{% endif %}
