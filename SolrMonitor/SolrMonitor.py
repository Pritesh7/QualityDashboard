__author__ = 'Pritesh'

import pysolr
from xml.dom import minidom
import urllib2
import psycopg2
import datetime


"""
SolrMonitor.py
The purpose of this script is to log Solr query response time and Solr Uptime.
"""

"""
Connect to the database
"""
conn = psycopg2.connect("dbname=quality_dashboard user=postgres password=postgres host=localhost")
cur = conn.cursor()

"""
Set up the solr connection each time
"""
solr_connection_string = 'http://10.211.55.100:8983/solr/xbrl_offline_shard1_replica1/'
solr_connection = pysolr.Solr(solr_connection_string)

"""
Ping the Solr Server
"""
ping_url = solr_connection_string + 'admin/ping/'
ping_response = urllib2.urlopen(ping_url).read()
ping_parsed = minidom.parseString(ping_response)
ping_elements = ping_parsed.getElementsByTagName('int')

for ping_element in ping_elements:
    print ping_element.firstChild.nodeValue
    if ping_element.getAttribute('name') == 'QTime':
        ping_value = int(ping_element.firstChild.nodeValue)

print datetime.datetime.now(), ping_value
cur.execute("INSERT INTO solr_uptime (request_time, response_time) values (%s, %s)", (datetime.datetime.now(), ping_value))
cur.execute("COMMIT")



"""
Retrieve a query response time - *:*
"""

response_query = '*:*'
response_return = solr_connection.search(response_query)
response_count = len(response_return)

cur.execute("INSERT INTO solr_query_time (request_time, response_time) VALUES (%s, %s)", (datetime.datetime.now(), response_count))
cur.execute("COMMIT")





conn.close()