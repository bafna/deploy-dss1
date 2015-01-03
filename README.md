# deploy-dss

1. Modify env=vagrant-vbox or staging accordinly in make_userdata.txt

2. For the first time, run first_time.sh. It will generate consul token and userdata.txt.

3. Add the machine ips in machines.txt. All the machines should be ssh enabled.

4. Run add_machine.sh to run userdata.txt on all the new machines.
