## Set your Preferred TimeZone

View your current setting:
```bash
timedatectl
```

View results. If it does not fits your own timezone, you can set it as you wish.
```bash
               Local time: Sun 2024-05-19 12:19:29 +03
           Universal time: Sun 2024-05-19 09:19:29 UTC
                 RTC time: Sun 2024-05-19 09:19:29
                Time zone: Europe/Istanbul (+03, +0300)
System clock synchronized: yes
              NTP service: active
          RTC in local TZ: no
```


First, list time zones, and select your zone:
```bash
timedatectl list-timezones
```

Use <kbd>up</kbd> , <kbd>down</kbd> keys, and <kbd>PgUp</kbd>/<kbd>PgDown</kbd> keys to navigate. Note or copy your selection.

Then, set it :
```bash
sudo timedatectl set-timezone Europe/Istanbul
```

Or enter the value in dockerrebuild.yml playbook.
```yaml
- name: Set timezone to Europe/Istanbul
  community.general.timezone:
    name: Europe/Istanbul
```
