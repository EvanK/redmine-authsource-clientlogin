-- NOTE: This insert needs to be run so Redmine knows to look for AuthSourceClientLogin
INSERT INTO auth_sources SET
  -- Let the database engine provide the id.
  id=NULL,
  -- Name of your AuthSource subclass
  type='AuthSourceClientLogin',
  -- Name of this alternative authentication source. Will be displayed in Administration UI pages.
  name='ClientLogin',
  -- Google ClientLogin authentication url.  If empty or nil, defaults to 'https://www.google.com/accounts/ClientLogin' (Thanks GData gem!)
  host='',
  -- Not used for this AuthSource
  port=0,
  -- The hosted domain to authenticate against.  Will be auto-appended to any login that doesnt have an '@domain.ext' appended to it
  account='gmail.com',
  -- Not used for this AuthSource
  account_password='',
  -- The accountType that we should use for authenticating (HOSTED_OR_GOOGLE, GOOGLE, HOSTED)
  base_dn='HOSTED_OR_GOOGLE',
  -- Not used for this AuthSource
  attr_login='',
  -- Not used for this AuthSource
  attr_firstname='',
  -- Not used for this AuthSource
  attr_lastname='',
  -- Not used for this AuthSource
  attr_mail='',
  -- Yes, if this source authenticates the user then Redmine should create an internal record for them (w/o password info).
  onthefly_register=1,
  -- Not used (as far as this AuthSource is concerned anyway)
  tls=0
;

