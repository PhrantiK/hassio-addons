# letsdnsocloud

Custom Domain with free Cloudflare DNS hosting, DDNS and Let's Encrypt (DNS Challenge)

Use a custom domain (subdomains supported) with Let's Encrypt on Hass.io without having to open port 80.

Dynamic DNS using the CloudFlare API baked in, updates every 5 mins.

##Quick & Dirty get started guide:

1. CloudFlare
  - 1.1 Sign up for free account
  - 1.2 Add your base domain (no need to create any DNS records)
  - 1.3 Make a note of the CloudFlare name servers
  - 1.4 Make a note of the Global API Key (under account details)
  - 1.5 Turn off the free SSL option under the Crypto menu (SSL to Off & Disable Universal SSL)

2. Change nameservers at your domain registrar to point to Cloudflare (Details from 1.3)

3. Home Router config
  - 3.1 Forward desired public facing port (TCP & UDP) to your Hassio local IP & port (default local port is 8123). Forward port 443 if you want to access externally without specifying a port. i.e https://yourdomain.com rather than https://yourdomain.com:1234

4. Hass.io config
  - 4.1 Go to Hass.io menu > Addon Store
  - 4.2 Enable Samba Share addon
  - 4.3 Mount addons share
  - 4.4 Download zip from Github
  - 4.5 Copy files into addons share
  - 4.6 Go back to to Hass.io menu > Addon Store > Local add-ons > letsdnsocloud
  - 4.7 Edit config file with your API Key (1.4), your CloudFlare email address and your domain.
  - 4.8 Hit start!
  - 4.9 Add the following to your configuration.yaml:
```
  http:
    base_url: https://your.domain.com:portnumber
    ssl_certificate: /ssl/fullchain.pem
    ssl_key: /ssl/privkey.pem
    ip_ban_enabled: true
    login_attempts_threshold: 5
```
  5. Restart homeassistant

  Let's Encrypt DNS Challenge code based on the Duckdns addon:
  https://github.com/home-assistant/hassio-addons/tree/master/duckdns
