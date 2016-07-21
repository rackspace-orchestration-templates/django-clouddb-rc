[![Circle CI](https://circleci.com/gh/rackspace-orchestration-templates/django-clouddb/tree/master.png?style=shield)](https://circleci.com/gh/rackspace-orchestration-templates/django-clouddb)
Description
===========

This is a template for deploying a Django application on multiple Linux servers
with [OpenStack Heat](https://wiki.openstack.org/wiki/Heat) on the [Rackspace
Cloud](http://www.rackspace.com/cloud/). A Load Balancer and Cloud Database
will also be deployed. This template is leveraging
[chef-solo](http://docs.opscode.com/chef_solo.html) to set up the server.

Requirements
============
* A Heat provider that supports the following:
  * OS::Nova::KeyPair
  * OS::Heat::RandomString
  * Rackspace::Cloud::LoadBalancer
  * OS::Heat::ResourceGroup
  * OS::Trove::Instance
* An OpenStack username, password, and tenant id.
* [python-heatclient](https://github.com/openstack/python-heatclient)
`>= v0.2.8`:

```bash
pip install python-heatclient
```

We recommend installing the client within a [Python virtual
environment](http://www.virtualenv.org/).

Example Usage
=============
Here is an example of how to deploy this template using the
[python-heatclient](https://github.com/openstack/python-heatclient):

```
heat --os-username <OS-USERNAME> --os-password <OS-PASSWORD> --os-tenant-id \
  <TENANT-ID> --os-auth-url https://identity.api.rackspacecloud.com/v2.0/ \
  stack-create djangoapp -f django_multi.yaml \
  -P project_name=myproject -P app_name=myapp
```

* For UK customers, use `https://lon.identity.api.rackspacecloud.com/v2.0/` as
the `--os-auth-url`.

Optionally, set environment variables to avoid needing to provide these
values every time a call is made:

```
export OS_USERNAME=<USERNAME>
export OS_PASSWORD=<PASSWORD>
export OS_TENANT_ID=<TENANT-ID>
export OS_AUTH_URL=<AUTH-URL>
```

Parameters
==========
Parameters can be replaced with your own values when standing up a stack. Use
the `-P` flag to specify a custom parameter.

* `server_hostname`: Host name to give the servers provisioned (Default:
  django-%index%)
* `project_name`: The name to use to create your Django project. (Default:
  mysite)
* `app_name`: The name of your Django application. (Default: myapp)
* `db_flavor`: Required: Rackspace Cloud Database Flavor. Size is based on
  amount of RAM for the provisioned instance. (Default: 1GB Instance)
* `image`: Required: Server image used for all servers that are created as a
  part of this deployment. (Default: Ubuntu 12.04 LTS (Precise Pangolin))
* `load_balancer_hostname`: Hostname for the Load Balancer (Default:
  Django-Load-Balancer)
* `venv_username`: Username with which to login to the Linux servers. This user
  will be the owner of the Python Virtual Environment under which Django is
  installed. (Default: pydev)
* `db_size`: Database instance size, in GB. min 10, max 150 (Default: 10)
* `flavor`: Required: Rackspace Cloud Server flavor to use. The size is based
  on the amount of RAM for the provisioned server. (Default: 4 GB Performance)
* `server_count`: Number of servers to deploy (Default: 2)
* `kitchen`: URL for the kitchen to use, fetched using git
  (Default: https://github.com/rackspace-orchestration-templates/django-clouddb)
* `virtualenv`: Python Virtual Environment in which Django will be installed.
  It will be created in the /srv directory. (Default: venv)
* `datastore_version`: Required: Version of MySQL to run on the Cloud Databases
  instance. (Default: 5.6)
* `child_template`: Location of child template
  (Default: https://raw.github.com/rackspace-orchestration-templates/django-clouddb/master/django-single.yaml)
* `db_user`: Required: Username for the database. (Default: db_user)
* `django_admin_email`: Email address (Default: admin@example.com)
* `django_admin_user`: Administrative username for logging into Django.
  (Default: djangouser)
* `chef_version`: Version of chef client to use (Default: 11.12.8)

Outputs
=======
Once a stack comes online, use `heat output-list` to see all available outputs.
Use `heat output-show <OUTPUT NAME>` to get the value fo a specific output.

* `private_key`: SSH Private Key
* `load_balancer_ip`: Load Balancer IP
* `server_ips`: Server IPs
* `db_user`: Database Username
* `django_url`: Django URL
* `db_pass`: Database User Password
* `db_name`: Database Name
* `db_host`: Database Host
* `django_admin_pass`: Django Admin Password

For multi-line values, the response will come in an escaped form. To get rid of
the escapes, use `echo -e '<STRING>' > file.txt`. For vim users, a substitution
can be done within a file using `%s/\\n/\r/g`.

Stack Details
=============
By default the application will be deployed under /var/www/application

Contributing
============
There are substantial changes still happening within the [OpenStack
Heat](https://wiki.openstack.org/wiki/Heat) project. Template contribution
guidelines will be drafted in the near future.

License
=======
```
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
