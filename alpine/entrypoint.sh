#!/bin/sh

# users can overwrite UWSGI_OPTIONS
if [ "$UWSGI_OPTIONS" == '' ]; then
  UWSGI_OPTIONS='--master --thunder-lock --enable-threads'
fi

# Run scheduler worker
if [ "$1" = 'scheduler' ]; then
  # switch to a particular Web2py version if specificed
  selectVersion
  # run python worker
  #run scheduled tasks for the specified apps: expects a
  #list of app names as -K app1,app2,app3 or a list of
  #app:groups as -K app1:group1:group2,app2:group1 to
  #override specific group_names. (only strings, no
  #spaces allowed. Requires a scheduler defined in the
  #models
  if [ "$WEB2PY_SCHEDULER_APPS" == '' ]; then
    echo "ERROR - WEB2PY_SCHEDULER_APPS not specified"
    exit 1
  fi
  exec python web2py.py -K '$WEB2PY_SCHEDULER_APPS'
fi

# Run uWSGI using the uwsgi protocol
if [ "$1" = 'uwsgi' ]; then
  # add an admin password if specified
  if [ "$WEB2PY_PASSWORD" != '' ]; then
    python -c "from gluon.main import save_password; save_password('$WEB2PY_PASSWORD',443)"
  fi
  # run uwsgi
  exec uwsgi --socket 0.0.0.0:9090 --protocol uwsgi --wsgi wsgihandler:application $UWSGI_OPTIONS
fi

# Run uWSGI using http
if [ "$1" = 'http' ]; then
  # disable administrator HTTP protection if requested
  if [ "$WEB2PY_ADMIN_SECURITY_BYPASS" = 'true' ]; then
    if [ "$WEB2PY_PASSWORD" == '' ]; then
      echo "ERROR - WEB2PY_PASSWORD not specified"
      exit 1
    fi
    echo "WARNING! - Admin Application Security over HTTP bypassed"
    python -c "from gluon.main import save_password; save_password('$WEB2PY_PASSWORD',8080)"
    sed -i "s/elif not request.is_local and not DEMO_MODE:/elif False:/" \
      $WEB2PY_ROOT/applications/admin/models/access.py
    sed -i "s/is_local=(env.remote_addr in local_hosts and client == env.remote_addr)/is_local=True/" \
      $WEB2PY_ROOT/gluon/main.py
  fi
  # run uwsgi
  exec uwsgi --http 0.0.0.0:8080 --wsgi wsgihandler:application $UWSGI_OPTIONS
fi

# Run using the builtin Rocket web server
if [ "$1" = 'rocket' ]; then
  # Use the -a switch to specify the password
  exec python web2py.py -a '$WEB2PY_PASSWORD' -i 0.0.0.0 -p 8080
fi

exec "$@"
