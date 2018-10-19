#! /bin/bash
#================================================================================
#
#    csmd/src/ras/ufm/convert_ufm_policy_to_csm_ras_types.sh 
#
#  © Copyright IBM Corporation 2015-2018. All Rights Reserved
#
#    This program is licensed under the terms of the Eclipse Public License
#    v1.0 as published by the Eclipse Foundation and available at
#    http://www.eclipse.org/legal/epl-v10.html
#
#    U.S. Government Users Restricted Rights:  Use, duplication or disclosure
#    restricted by GSA ADP Schedule Contract with IBM Corp.
#
#================================================================================

# print the header to match the csm_ras_type_data.csv format 
echo "#msg_id,severity,message,description,control_action,threshold_count,threshold_period,enabled,set_state,visible_to_users"

while IFS=, read -r AlarmId Message Severity
do
 
  # Remove trailing spaces followed by quotes
  Message="${Message// \"}"
 
  # Remove all other quotes
  Message="${Message//\"}"
  Severity="${Severity//\"}"

  # Replace (%) with Percent
  Message="${Message//(%)/Percent}"

  # Generate msg_id from AlarmId 
  MsgId="ufm.$AlarmId"
 
  # Map UFM Severity to CSM RAS Severity
  # UFM supports Info, Warning, Minor, Critical
  # CSM RAS supports INFO, WARNING, FATAL
  if [ "$Severity" == "Info" ] ; then
    Severity="INFO"
  elif [ "$Severity" == "Critical" ] ; then
    Severity="FATAL"
  else
    Severity="WARNING"
  fi
 
  #Message=""
  Description=""
  #Severity="INFO"
  
  # Default all of these for now
  ControlAction="NONE"
  ThresholdCount="1"
  ThresholdPeriod="0"
  Enabled="true"
  SetState=""
  VisibleToUsers="true"

  #msg_id,severity,message,description,control_action,threshold_count,threshold_period,enabled,set_state,visible_to_users
  echo "$MsgId,$Severity,$Message,$Description,$ControlAction,$ThresholdCount,$ThresholdPeriod,$Enabled,$SetState,$VisibleToUsers"
 
# Replace commas contained within quoted fields with spaces:
# awk -F'"' -v OFS='"' '{ for (i=2; i<=NF; i+=2) gsub(",", " ", $i) } {print $0}'
 
done < <( cat /opt/ufm/scripts/policy.csv | awk -F'"' -v OFS='"' '{ for (i=2; i<=NF; i+=2) gsub(",", " ", $i) } {print $0}' | awk -F, '{print $1","$2","$15}' ) | sort

