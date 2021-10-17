def test_packages(host):
    packages = ['firewalld','kmod-wireguard','wireguard-tools']
    for i in packages:
        assert host.package(i).is_installed

def test_services(host):
    services = ['firewalld','wg-quick@wg0']
    for i in services:
        assert host.service(i).is_running
        assert host.service(i).is_enabled