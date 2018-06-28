{% from "apache/map.jinja" import apache with context %}

{% if grains['os_family']=="FreeBSD" %}

include:
  - apache

{{ apache.confdir }}/httpd-info.conf:
  file.managed:
    - source: 
      - salt://apache/files/{{ salt['grains.get']('os_family') }}/mod_info.conf.jinja
    - mode: 644
    - template: jinja
    - require:
      - pkg: apache

{% endif %}
