#
# Cookbook Name:: python-django
# Recipe:: default
#
# Copyright (C) 2013 Rackspace
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "apt" if platform_family?("debian")
include_recipe "apache2::default"
include_recipe "apache2::mod_wsgi"
include_recipe "mysql::client"
include_recipe "python"

venv = node['django']['virtualenv']
project_name = node['django']['project_name']
app_name = node['django']['app_name']
dev_user = node['django']['username']

user dev_user do
    password node['django']['password']
    supports :manage_home => true
    shell "/bin/bash"
    home "/home/#{dev_user}"
    action :create
end

directory "/srv/#{venv}" do
    owner dev_user
    group dev_user
    mode 02775
    action :create
end

bash "create virtual environment /src/#{venv}" do
    code "su -c 'virtualenv /srv/#{venv}' - #{dev_user}"
    not_if { ::File.exists?(File.join("/srv", venv, "bin", "pip")) }
end

package 'libjpeg-dev'

python_pip "django" do
    virtualenv "/srv/#{venv}"
    user dev_user
    group dev_user
    action :install
end

python_pip "pillow" do
    virtualenv "/srv/#{venv}"
    user dev_user
    group dev_user
    action :install
end

python_pip "mysql-python" do
    virtualenv "/srv/#{venv}"
    user dev_user
    group dev_user
    action :install
end

bash "create_django_project" do
    environment 'HOME' => "/home/#{dev_user}",
        "VIRTUAL_ENV" => "/srv/#{venv}"
    code "su -c 'cd /srv/#{venv}; bin/python bin/django-admin.py startproject #{project_name}' - #{dev_user}"
    creates "/srv/#{venv}/#{project_name}/manage.py"
    action :run
end

if node['django']['source_url'] != ""
    if node['django']['source_type'].eql?('git')
        package "git" do
            action :install
        end

        git "/srv/#{venv}/#{project_name}/#{app_name}" do
            repository node['django']['source_url']
            action :sync
        end
    elsif node['django']['source_type'].eql?('distribute')
        remote_file "/srv/#{venv}/#{app_name}.tar.gz" do
            source node['django']['source_url']
            mode "0644"
            owner dev_user
            group dev_user
            not_if { ::File.exists?("/srv/#{venv}/#{app_name}.tar.gz") }
        end

        python_pip "/srv/#{venv}/#{app_name}.tar.gz" do
            virtualenv "/srv/#{venv}"
            user dev_user
            group dev_user
            action :install
        end
    end
end

template "/srv/#{venv}/#{project_name}/#{project_name}/settings.py" do
    source "settings.py.erb"
end

template "/srv/#{venv}/#{project_name}/#{project_name}/urls.py" do
    source "urls.py.erb"
end

template "/srv/#{venv}/#{project_name}/#{project_name}/wsgi.py" do
    source "wsgi.py.erb"
end

# Add custom Apache wsgi configuration
apache_conf "wsgi"

# Following command will makes sure the custom config file is linked
bash "Link wsgi.conf to mods-enabled" do
    code "a2enmod wsgi; service #{node['apache']['package']} restart"
    not_if { ::File.exists?(File.join(node['apache']['dir'], "mods-enabled", "wsgi.conf")) }
end

web_app project_name do
    template "apache.erb"
    projname project_name
    case node['platform_family']
    when "debian"
        apache_name "apache2"
    else
        apache_name "httpd"
    end
    a2venv venv
end

bash "syncdb_collectstatic" do
    environment 'HOME' => "/home/#{dev_user}",
        "VIRTUAL_ENV" => "/srv/#{venv}"
    code "su -c 'cd /srv/#{venv}/#{project_name}; ../bin/python manage.py collectstatic --noinput; ../bin/python manage.py migrate --noinput' - #{dev_user}"
    creates "/srv/#{venv}/static"
    action :run
end

bash "create_django_superuser" do
    environment 'HOME' => "/home/#{dev_user}",
        "VIRTUAL_ENV" => "/srv/#{venv}"
    code <<-EOS
su -c 'cd /srv/#{venv}/#{project_name}; echo "from django.contrib.auth.models import User; User.objects.create_superuser(\\"#{node['django']['django_admin_user']}\\", \\"#{node['django']['django_admin_email']}\\", \\"#{node['django']['django_admin_pass']}\\")" | ../bin/python manage.py shell' - #{dev_user}
    EOS
    action :run
end

node['django']['additional_commands'].each do |cmd|
    bash cmd do
        environment 'HOME' => "/home/#{dev_user}",
            "VIRTUAL_ENV" => "/srv/#{venv}"
        code "su -c 'cd /srv/#{venv}/#{project_name}; ../bin/python manage.py #{cmd}' - #{dev_user}"
        action :run
    end
end

directory "/srv/#{venv}/#{project_name}/#{project_name}/templates" do
    owner dev_user
    group dev_user
    mode 02775
    action :create
    only_if {node['django']['app_name'] == 'django_cms'}
end

cookbook_file "/srv/#{venv}/#{project_name}/#{project_name}/templates/base.html" do
    source "base.html"
    mode 0644
    owner dev_user
    group dev_user
    only_if {node['django']['app_name'] == 'django_cms'}
end

cookbook_file "/srv/#{venv}/#{project_name}/#{project_name}/templates/template_1.html" do
    source "template_1.html"
    mode 0644
    owner dev_user
    group dev_user
    only_if {node['django']['app_name'] == 'django_cms'}
end
