<!-- Getting Raspberry Pi CM5 ready for running Ubuntu -->
Run Raspberry Pi imager and use ubuntu server 25 LTS image ARM64
Enable SSH and SSH hardening step below to improve security as we are building a production cluster.
As a bastion host, this will be the main tunnel to our production cluster.

<!-- Note: Make sure to copy over the correct pub key

<!-- SSH Hardening Steps defined for scripting -->
1. Apply iptables as firewall (/)
2. Change Default SSH Ports (/)
3. Disable SSH Protocal 1 (/)
4. Disable Direct Root Login (/)
5. Enforce SSH Key authentication and disable passwords (/)
6. Limit SSH Access to Specific Users and Groups (/)
7. Use Two-Factor Authentication (Maybe)
8. Monitor and Audit SSH Access (More of an ongoing thing)
9. Backup configurations
10. Install Fail2Ban (may be a manual install.)

Ref: https://www.interserver.net/tips/kb/hardening-ssh-access-on-ubuntu-vps-the-ultimate-guide/

Run the followin:
1.local_key_gen.sh
2.bastion_host_hardening.sh


