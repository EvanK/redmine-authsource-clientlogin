# Google ClientLogin Authentication for Redmine #

**NOTE**: This is still in an very early non-stable state (ie: may break without warning or reason).

## Installation ##

First of all, you may need to install the [Google Data APIs Ruby Utility Library](http://code.google.com/p/gdata-ruby-util/).  I'm working off of version 1.1.1, though earlier versions may work.

    sudo gem install gdata -v 1.1.1

Next, insert a new record into your Redmine's `auth_sources` table.  An example insert can be found in the included `auth_source.sql` file.  Items of note in said SQL include:

* account - The default domain to authenticate against, for example a [Google Apps hosted domain](https://www.google.com/a/)
* base_dn - The accountType that we should use for authenticating, [see ClientLogin documentation](http://code.google.com/apis/accounts/docs/AuthForInstalledApps.html#Request) for more details
* onthefly_register - Yes, if this source authenticates the user then Redmine should create an internal record for them (w/o password info)

Finally, place the included `auth_source_clientlogin.rb` file in your Redmine codebase under `app/models/` and restart Redmine.

### But wait...It's not working! ###

If you have followed the above instructions, check any [known issues](http://github.com/EvanK/redmine-authsource-clientlogin/issues).  If that doesn't shed any light, please feel free to file a new issue.