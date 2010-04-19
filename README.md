# Google ClientLogin Authentication for Redmine #

**NOTE**: This is still in an very early non-stable state (ie: may break without warning or reason).

## Installation ##

First of all, you may need to install the [Google Data APIs Ruby Utility Library](http://code.google.com/p/gdata-ruby-util/).  I've verified this code works with as early as version 1.1.0 of the gem.

    sudo gem install gdata

Next, insert a new record into your Redmine's `auth_sources` table.  An example insert can be found in the included `auth_source.sql` file.  Items of note in said SQL include:

* account - The default domain to authenticate against, for example a [Google Apps hosted domain](https://www.google.com/a/)
* base_dn - The accountType that we should use for authenticating, [see ClientLogin documentation](http://code.google.com/apis/accounts/docs/AuthForInstalledApps.html#Request) for more details
* onthefly_register - Yes, if this source authenticates the user then Redmine should create an internal record for them (w/o password info)

Finally, place the included `auth_source_clientlogin.rb` file in your Redmine codebase under `app/models/` and restart Redmine.

### But wait...Something's not working! ###

If you have followed the above instructions, check any [known issues](http://github.com/EvanK/redmine-authsource-clientlogin/issues).  If that doesn't shed any light, please feel free to file a new issue.

### What if I already have users set up with the built-in authentication? ###

Changing their authentication method is fairly trivial if my experience is any indication.  That said, it does require some direct changes to your backend database, so before you try this **you should make a complete and current backup of your database** if you don't already have one.  I shall repeat this because it bears repeating: **you should make a complete and up-to-date backup of your Redmine database before doing any of the following steps!**

First things first, the user(s) you're meddling with should have their email address in Redmine set to a Gmail or Google Apps address that supports the ClientLogin protocol.

Now, assuming you've installed our new AuthSource subclass, we need its unique id from the auth_sources table.  We can get this with a simple SQL query:

    mysql> SELECT id FROM auth_sources WHERE type='AuthSourceClientLogin';
    +----+
    | id |
    +----+
    |  1 |
    +----+
    1 row in set

Now, for the user(s) we're going to modify, we'll need to change the `login` field to their current email address, clear their `hashed_password`, and set their `auth_source_id` to the value we retrieved in the previous step:

    mysql> UPDATE users SET login=mail, hashed_password='', auth_source_id=1 WHERE login='evan';
    Query OK, 1 row affected (0.00 sec)
    Rows matched: 1  Changed: 1  Warnings: 0

The user(s) in question should now be able to login with their Google-hosted email address and password!  Note that **their username has actually changed** from whatever it was before to their full email address!

