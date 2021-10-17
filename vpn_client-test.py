import re

def test_packages(host):
    packages = ['firewalld','kmod-wireguard','wireguard-tools']
    for i in packages:
        assert host.package(i).is_installed

def test_firewalld_service(host):
    assert host.service('firewalld').is_running
    assert host.service('firewalld').is_enabled

def test_remote_host(host):
    with host.sudo():
        conffile = host.file('/etc/wireguard/wg0.conf').content
    string = list(conffile.split(b'\n'))
    for line in string:
        if line.startswith(b'Endpoint'):
            stringline = line.decode("utf-8")
            ip = re.search(r'\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}', stringline).group()
    remotehost = host.addr(ip)
    print(type(ip))
    assert remotehost.is_reachable
