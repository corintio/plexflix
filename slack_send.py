#!/usr/bin/env python3
import sys
import os

# Posting to a Slack channel
def send_message_to_slack(icon, msg, text):
    from urllib import request, parse
    import json
    attachment = "```{0}```".format(text) if text else ""
    post = {"text": "{0} {1} {2}".format(icon, msg, attachment)}
 
    try:
        json_data = json.dumps(post)
        req = request.Request(os.environ['SLACK_URL'],
                              data=json_data.encode('ascii'),
                              headers={'Content-Type': 'application/json'}) 
        resp = request.urlopen(req)
    except Exception as em:
        print("EXCEPTION: " + str(em))
 
prog, icon, msg, *text = sys.argv
send_message_to_slack(icon, msg, " ".join(text))