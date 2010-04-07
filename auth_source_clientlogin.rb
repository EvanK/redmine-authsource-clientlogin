# redMine - project management software
# Copyright (C) 2006  Jean-Philippe Lang
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

# ClientLogin by Evan Kaufman
# http://github.com/EvanK/redmine-authsource-clientlogin

require 'gdata/auth'
require 'gdata/http'

class AuthSourceClientLogin < AuthSource
  def authenticate(login, password)
    return nil if login.blank? || password.blank?
    
    # get domain segment from login if available (which is presumably in email format)
    login = login.strip
    login_domain = login.split('@')
    
    # if only hosted accounts are allowed, then kick them back if they supply a different domain than what is in {self.account} (but not if they don't supply a domain at all!)
    if self.base_dn == 'HOSTED' && login_domain[1] != nil && login_domain[1] != self.account
      logger.debug "Refusing to authenticate '#{login}', not hosted under '#{self.account}'" if logger && logger.debug?
      return nil
    end
    # if they don't supply a domain at all, kick them back
    # NOTE: originally planned to auto-append domain {self.account}, but redmine sees 'jdoe@domain.com' and 'jdoe' as two seperate users...
    if login_domain[1] == nil
      logger.debug "ClientLogin username must be in user@domain format" if logger && logger.debug?
      return nil
    end
    
    begin
      # attempt authentication (will raise BadAuthentication error if it fails)
      # NOTE: have yet to find a way around ClientLogin captcha issue...
      source_name = self.account.sub(/[^a-z0-9]+/, '') + '-redMine-0.1'
      login_handler = GData::Auth::ClientLogin.new('cp', :account_type => self.base_dn)
      login_handler.get_token(login, password,  source_name)
      client = GData::Client::Contacts.new(:auth_handler => login_handler)
      # get full contact feed and extract first contact with given login as their email
      # NOTE: if the user has > 100 contacts, just don't worry about scouring for their name...Redmine will ask them during signup anyway
      feed = client.get('https://www.google.com/m8/feeds/contacts/default/full?max-results=100').to_xml
      logger.error "dumping xml: #{feed}"
      contact_name = feed.elements["/feed/entry[gd:email/@address='#{login}']/title"]
      # if we found one, extract their title/name and split into first and last
      full_name = contact_name == nil ? [] : contact_name.first.value.split(/\s+/, 2)
      # assemble & return user attributes as best we could determine them
      attrs = [
        :login => login,
        :mail => login,
        :firstname => full_name[0] || '',
        :lastname => full_name[1] || '',
        :auth_source_id => self.id
      ]
      return attrs
    rescue => e
      logger.error "Error during authentication: #{e.message}"
      return nil
    end
  end
  
  def auth_method_name
    "ClientLogin"
  end
end


