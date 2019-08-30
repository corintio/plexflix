#!/bin/bash

# From: http://blog.pragbits.com/it/2015/02/09/slack-notifications-via-curl/

function post_to_slack () {
  # format message as a code block ```${msg}```
  SLACK_MESSAGE="\`\`\`$2\`\`\`"
  # SLACK_URL=https://hooks.slack.com/services/your-service-identifier-part-here
  
  case "$1" in
    INFO)
      SLACK_ICON=':information_source:'
      ;;
    WARNING)
      SLACK_ICON=':warning:'
      ;;
    ERROR)
      SLACK_ICON=':bangbang:'
      ;;
    *)
      SLACK_ICON=':slack:'
      ;;
  esac

  curl -X POST --data "{\"text\": \"${SLACK_ICON} ${SLACK_MESSAGE}\"}" ${SLACK_URL} 
}

LEVEL=$1
shift
MSG="$@"
post_to_slack $LEVEL "$MSG"