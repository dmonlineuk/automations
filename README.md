# automations

This will contain stuff designed to run in the home automations machine.

# Setup

Will need to install required packages. Use the following:

  - `sudo apt install $(cat requirements.txt)`

For automated scripts, the .service and .timer files should be copied to /etc/systemd/system/ but check the contents of these as the paths should be absolute and will not be reflective of the actual location of the repo and scripts.

## Dynamic DNS

1. Create the secrets as required. I follow the `suiss cheese` model; I understand my key file used for encryption is still in the clear, however I do like giving bad actors as many layers to go through as I can to get to the secrets.
  - `openssl rand -hex 32 > ~/.secrets/key && chmod 600 ~/.secrets/key`
  - `openssl enc -aes-256-cbc -pbkdf2 -iter 1000000 -salt -in {file.in.clear} -out {encrypted.file} -pass file:$HOME/.secrets/key && chmod 600 {encrypted.file} && rm {file.in.clear}`
2. Update a copy of .env.example (named as .env) - this needs to have the actual domain name and hostame, as well as paths to secret and key files
3. Copy and edit the service and timer files into /etc/systemd/system/
4. Enable timer and review logs
  - Enable
  - `sudo systemctl daemon-reload`
  - `sudo systemctl enable --now dynamicdns.timer`

  - Check
  - `systemctl status dynamicdns.timer`

  - Review logs
  - `journalctl -u dynamicdns.service`
5. Check the logs from the script's internal code using `journalctl -t dynamicdns`

## External Connectivity Checks

Uses speedtest cli (ookla) to check internet access and speed. Sends results to user.info with tag 'connectivity'

1. Copy and edit the service and timer files into /etc/systemd/system/
2. Enable timer and review logs
  - Enable
  - `sudo systemctl daemon-reload`
  - `sudo systemctl enable --now checkextconn.timer`

  - Check
  - `systemctl status checkextconn.timer`

  - Review logs
  - `journalctl -u checkextconn.service`
3. Check the logs from the script's internal code using `journalctl -t connectivity`

