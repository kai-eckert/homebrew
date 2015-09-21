#
# Cookbook Name:: homebrew
# Providers:: cask
#
# Copyright 2011-2015, Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'chef/mixin/shell_out'
include Chef::Mixin::ShellOut
include ::Homebrew::Mixin

use_inline_resources

def whyrun_supported?
  true
end

def load_current_resource
  @cask = Chef::Resource::HomebrewCask.new(new_resource.name)
  Chef::Log.debug("Checking whether #{new_resource.name} is installed")
  @cask.casked shell_out("/usr/local/bin/brew cask list | grep #{new_resource.name}").exitstatus == 0
end

action :install do
  execute "installing cask #{new_resource.name}" do
    command "/usr/local/bin/brew cask install #{new_resource.name} #{new_resource.options}"
    user homebrew_owner
    not_if { @cask.casked }
  end
end

action :uninstall do
  execute "uninstalling cask #{new_resource.name}" do
    command "/usr/local/bin/brew cask uninstall #{new_resource.name}"
    user homebrew_owner
    only_if { @cask.casked }
  end
end

alias_method :action_cask, :action_install
alias_method :action_uncask, :action_uninstall
