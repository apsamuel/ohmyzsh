# Django plugin

This plugin adds completion for the [Django Project](https://www.djangoproject.com/) commands
(`manage.py`, `django-admin`, ...).

## Deprecation (2021-09-22)

The plugin used to provide completion for `./manage.py` and `django-admin`, but Zsh already provides
a better, more extensive completion for those, so this plugin is no longer needed.

## Usage

```zsh
$> python manage.py (press <TAB> here)
```

Would result in:

```zsh
cleanup                    -- remove old data from the database
compilemessages            -- compile .po files to .mo for use with gettext
createcachetable           -- creates table for SQL cache backend
createsuperuser            -- create a superuser
dbshell                    -- run command-line client for the current database
diffsettings               -- display differences between the current settings and Django defaults
dumpdata                   -- output contents of database as a fixture
flush                      -- execute 'sqlflush' on the current database
inspectdb                  -- output Django model module for tables in database
loaddata                   -- install the named fixture(s) in the database
makemessages               -- pull out all strings marked for translation
reset                      -- executes 'sqlreset' for the given app(s)
runfcgi                    -- run this project as a fastcgi
runserver                  -- start a lightweight web server for development
...
```

If you want to see the options available for a specific command, try:

```zsh
$> python manage.py makemessages (press <TAB> here)
```

And that would result in:

```zsh
--all         -a  -- re-examine all code and templates
--domain      -d  -- domain of the message files (default: "django")
--extensions  -e  -- file extension(s) to examine (default: ".html")
--help            -- display help information
--locale      -l  -- locale to process (default: all)
--pythonpath      -- directory to add to the Python path
--settings        -- python path to settings module
...
```

