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
    # if they don't supply a domain at all, automatically append the domain in {self.account}
    if login_domain[1] == nil
      login = login_domain[0] + '@' + self.account
    end
    
    begin
      # get authentication token
      # if self.host is given, authenticate against it...otherwise, GData class will use default url
      client_login_opts = Hash.new
      client_login_opts[:account_type] = self.base_dn
      if self.host != nil && self.host != ''
        client_login_opts[:auth_url] = self.host
      end
      # attempt authentication (presumably against google)
      client_login_handler = GData::Auth::ClientLogin.new('cl', client_login_opts)
      token = client_login_handler.get_token(login, password,  self.account.sub(/[^a-z0-9]+/, '') + '-redMine-0.1')
      # get calendar feed (in order to get author data)
      cal_client = GData::Client::Calendar.new(:auth_handler => client_login_handler)
      response = cal_client.make_request(:get, 'https://www.google.com/calendar/feeds/default/owncalendars/full')
      # parse and return xml data as REXML::Document object
      response_xml = response.to_xml()
      attrs = Hash.new
      # get email from xml if available, or default to login name
      attrs[:login] = REXML::XPath.first(response_xml, '/feed/author/email') || login
      attrs[:mail] = attrs[:mail]
      # get name and split on whitespace, or default to empty strings
      name_segments = REXML::XPath.first(response_xml, '/feed/author/name').to_s.split(/\s+/, 2)
      attrs[:firstname] = name_segments[0] || ''
      attrs[:lastname] = name_segments[1] || ''
      # if we've gotten this far, it may have actually worked...cool!
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

