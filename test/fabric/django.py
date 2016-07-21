from fabric.api import env, task
from envassert import detect, file, group, package, port, process, service, \
    user
from hot.utils.test import get_artifacts


@task
def check():
    env.platform_family = detect.detect()

    assert package.installed("apache2")
    assert file.exists("/srv/venv/bin/django-admin.py")
    assert file.exists("/etc/apache2/mods-enabled/wsgi.conf")
    assert file.exists("/etc/apache2/mods-enabled/wsgi.load")
    assert port.is_listening(80)
    assert user.exists("pydev")
    assert group.is_exists("pydev")
    assert user.is_belonging_group("pydev", "pydev")
    assert process.is_up("apache2")
    assert service.is_enabled("apache2")


@task
def artifacts():
    env.platform_family = detect.detect()
    get_artifacts()
