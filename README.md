# simple-cloudflare-ddns-ipv6
Simple Cloudflare DDNS for IPv6

I know that multiple Cloudflare DDNS exist on GitHub. However, I'm struggling to make them work. So, I just asked ChatGPT to write a shell script for me and want to share the code here. 

## Prerequisite
You need Cloudflare's `API TOKEN` and `ZONE ID` 

### API TOKEN

1. Go to [API Token](https://dash.cloudflare.com/profile/api-tokens) page in Cloudflare settings and click "Create token"

![Creat Token](https://github.com/user-attachments/assets/4882af85-f4b0-4a8f-bb79-07d34d7e815e)

2. Use Edit Zone DNS template

![Use Edit Zone DNS Template](https://github.com/user-attachments/assets/f28bcfc1-44fa-44ac-a460-9229ee09ab3f)

3. Add these 3 permission and add your domain to the zone resource

![add permission](https://github.com/user-attachments/assets/8a3f4fea-498d-49b6-8fb5-821607274e3e)

4. Then, you will get the token. Please add this to the `ddns.sh` script in the installtion process.
![image](https://github.com/user-attachments/assets/ecc18125-a17d-4ab4-be2e-651f11271115)


### Zone ID 

Click on the Overview page of your domain name. It will be shown on the right of the page.

![image](https://github.com/user-attachments/assets/fd0f4bb6-7134-4b2f-a1f1-95097dfacbe5)



## Installation. 
### 1. Download the script

```
wget -O ~/ddns.sh https://raw.githubusercontent.com/pureexe/simple-cloudflare-ddns-ipv6/refs/heads/main/ddns.sh
chmod +x ~/ddns.sh
```

### 2. Edit your API Key, Zone ID, and Subdomain that you want to run DDNS on 

```
nano ~/ddns.sh
```

### 3. Make it repeatedly update every 6 hours
You can change the frequency of updating. But I will set it to every 6 hours by using the crontab command 

```
crontab -e
```

If it asks you to select editor, just use `nano`, which is the simplest, and then add the following line at the end of the file.

Don't forget to change `YOURHOMEDIRECTORY` to your home directory path.

```
0 */6 * * * /bin/bash /home/YOURHOMEDIRECTORY/ddns.sh
```

