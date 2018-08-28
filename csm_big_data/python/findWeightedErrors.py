#!/bin/python
# encoding: utf-8
#================================================================================
#
#    findUserJobs.py
#
#    © Copyright IBM Corporation 2015-2018. All Rights Reserved
#
#    This program is licensed under the terms of the Eclipse Public License
#    v1.0 as published by the Eclipse Foundation and available at
#    http://www.eclipse.org/legal/epl-v10.html
#
#    U.S. Government Users Restricted Rights:  Use, duplication or disclosure
#    restricted by GSA ADP Schedule Contract with IBM Corp.
#
#================================================================================


import argparse
import sys
import os

from datetime import datetime
from dateutil.parser import parse
from elasticsearch import Elasticsearch
from elasticsearch.serializer import JSONSerializer

import cast_helper as cast

TARGET_ENV='CAST_ELASTIC'


def main(args):

    # Specify the arguments.
    parser = argparse.ArgumentParser(
        description='''A tool for finding a list of the supplied user's jobs.''')
    

    parser.add_argument( '-u', '--user', metavar='username', dest='user', default=None,
        help="The user name to perform the query on, either this or -U must be set.")
    parser.add_argument( '-U', '--userid', metavar='userid', dest='userid', default=None,
        help="The user id to perform the query on, either this or -u must be set.")
    parser.add_argument( '--size', metavar='size', dest='size', default=1000,
        help='The number of results to be returned. (default=1000)')
    parser.add_argument( '--state', metavar='state', dest='state', default=None, 
        help='Searches for jobs matching the supplied state.')

    parser.add_argument( '--starttime', metavar='YYYY-MM-DD HH:MM:SS', dest='starttime', default=None,
        help='A timestamp representing the beginning of the absolute range to look for failed jobs, if not set no lower bound will be imposed on the search.')
    parser.add_argument( '--endtime', metavar='YYYY-MM-DD HH:MM:SS', dest='endtime', default=None,
        help='A timestamp representing the ending of the absolute range to look for failed jobs, if not set no upper bound will be imposed on the search.')

    parser.add_argument( '--errormap', metavar="file", dest="err_map_file", default=None,
        help='A map of errors to scan the user jobs for, including weights.')

    parser.add_argument( '-v', '--verbose', action='store_true',
        help='Displays all retrieved fields from the `cast-allocation` index.')

    parser.add_argument( '-t', '--target', metavar='hostname:port', dest='target', default=None, 
        help='An Elasticsearch server to be queried. This defaults to the contents of environment variable "CAST_ELASTIC".')


    args = parser.parse_args()

    # If the target wasn't specified check the environment for the target value, printing help on failure.
    if args.target == None:
        if TARGET_ENV in os.environ:
            args.target = os.environ[TARGET_ENV]
        else:
            parser.print_help()
            print("Missing target, '%s' was not set." % TARGET_ENV)
            return 2

    if args.user is None and args.userid is None:
        parser.print_help()
        print("Missing user, --user or --userid must be supplied.")
        return 2
    
    error_map=None
    if args.err_map_file:
        error_map = JSONSerializer().loads(open(args.err_map_file).read())

    if error_map is None:
        print("Error map file was not properly specified (--errormap).")
        return 3

    
    # Open a connection to the elastic cluster, if this fails is wrong on the server.
    es = Elasticsearch(
        args.target, 
        sniff_on_start=True,
        sniff_on_connection_fail=True,
        sniffer_timeout=60
    )

    # Ammend compute nodes for common node search.
    fields=cast.USER_JOB_FIELDS + ["data.compute_nodes"]

    resp = cast.search_user_jobs(es, 
        user_name  = args.user, 
        user_id    = args.userid,
        job_state  = args.state,
        start_time = args.starttime,
        end_time   = args.endtime,
        size       = args.size)

    print(error_map)
        

    # Parse the response from elasticsearch.
    hits       = cast.deep_get(resp, "hits", "hits")
    total_hits = cast.deep_get(resp, "hits","total")


if __name__ == "__main__":
    sys.exit(main(sys.argv))
