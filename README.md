# letsdnsocloud

## Custom Domain with free Cloudflare DNS hosting, DDNS and Let's Encrypt (DNS Challenge)

Use a custom domain (subdomains supported) with Let's Encrypt on Hass.io without having to open port 80.

Dynamic DNS using the CloudFlare API baked in, updates every 5 mins.

## Quick & Dirty get started guide:

1. ### CloudFlare
  - Sign up for free account
  - Add your base domain (no need to create any DNS records)
  - Make a note of the CloudFlare name servers
  - Turn off the free SSL option under the Crypto menu (SSL to Off & Disable Universal SSL)

2. ### Domain Registrar
  - Change nameservers for your domain to point to Cloudflare.

3. ### Home Router
  - Forward desired public facing port (TCP & UDP) to your Hassio local IP & port (default local port is 8123).
  >Forward port 443 if you want to access externally without specifying a port. i.e https://yourdomain.com rather than https://yourdomain.com:1234

4. ### Hassio config
  - Go to Hass.io menu > Addon Store
  - Enable Samba Share addon
  - Mount addons share in your OS
  - Download zip from Github (or git clone into addons share)
  - Copy files into addons share
  - Go back to to Hass.io menu > Addon Store (hit refresh, top right) > Local add-ons > letsdnsocloud
  - Edit config file with your CloudFlare Global API Key, your CloudFlare email address and domain.
  - Hit start and wait for it to create the certificates.
  - Add the following to your configuration.yaml:
```
  http:
    base_url: https://your.domain.com:portnumber
    ssl_certificate: /ssl/fullchain.pem
    ssl_key: /ssl/privkey.pem
    ip_ban_enabled: true
    login_attempts_threshold: 5
```
>ip ban optional but recommended

  5. ### Restart homeassistant

Let's Encrypt DNS Challenge code based on the Duckdns addon:

https://github.com/home-assistant/hassio-addons/tree/master/duckdns
