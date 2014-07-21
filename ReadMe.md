# Quality Dashboard

## Build the Dockerfile

```
docker build . -t quality_dashboard
```

## Edit the python script - SolrMonitor.py - to ensure it is pointing to your solr url

```
vim /home/quality_assurance/SolrMonitor/SolrMonitor.py
```

## Start the Postgres and Cron daemon services

```
service postgresql-9.3 start
service crond start
```

## Setup the cron job

```
crontab -e
```

Add the following line:

```
 * * * * * /usr/bin/python /home/quality_assurance/SolrMonitor/SolrMonitor.py > /dev/null 2>&1
```

Edit the following file:

```
vim /etc/pam.d/crond
```

Comment out the line below by aadding a hash in-front of it

```
#session    required   pam_loginuid.so
```

Restart the cron daemon

```
service crond restart
```
 
## Verify the cron job
```
psql -U postgres -d quality_dashboard
(password: postgres)
psql> SELECT * FROM solr_uptime;
psql> SELECT * FROM soly_query_time;
```