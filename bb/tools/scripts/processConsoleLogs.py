#!/usr/bin/python
###########################################################
#     processConsoleLogs.py
#
#     Copyright IBM Corporation 2015,2016. All Rights Reserved
#
#     This program is licensed under the terms of the Eclipse Public License
#     v1.0 as published by the Eclipse Foundation and available at
#     http://www.eclipse.org/legal/epl-v10.html
#
#     U.S. Government Users Restricted Rights:  Use, duplication or disclosure
#     restricted by GSA ADP Schedule Contract with IBM Corp.
###########################################################


import copy
import os
import re
import pprint
import sys

import common as cmn


#
# Helper routines for ElapsedTimeData
#

def addJobIdData(pCtx, pLogDate, pLogTime, pJobId, pServerName, pConnection, pSizeTransferred):
    l_ElapsedTimeEntry = pCtx["ElapsedTimeData"]["jobIds"]

    l_ElapsedTimeEntry[pJobId] = {}
    l_ElapsedTimeEntry[pJobId]["StartDateTime"] = (pLogDate, pLogTime)
    l_ElapsedTimeEntry[pJobId]["EndDateTime"] = (pLogDate, pLogTime)
    l_ElapsedTimeEntry[pJobId]["SizeTransferred"] = pSizeTransferred

    l_ElapsedTimeEntry[pJobId]["servers"] = {}
    addServerData(pCtx, pLogDate, pLogTime, pJobId, pServerName, pConnection, pSizeTransferred)

    l_ElapsedTimeEntry[pJobId]["servers"][pServerName]["connections"] = {}
    addConnectionData(pCtx, pLogDate, pLogTime, pJobId, pServerName, pConnection, pSizeTransferred)

    return

def addServerData(pCtx, pLogDate, pLogTime, pJobId, pServerName, pConnection, pSizeTransferred):
    l_ElapsedTimeEntry = pCtx["ElapsedTimeData"]["jobIds"][pJobId]["servers"]

    l_ElapsedTimeEntry[pServerName] = {}
    l_ElapsedTimeEntry[pServerName]["StartDateTime"] = (pLogDate, pLogTime)
    l_ElapsedTimeEntry[pServerName]["EndDateTime"] = (pLogDate, pLogTime)
    l_ElapsedTimeEntry[pServerName]["SizeTransferred"] = pSizeTransferred

    l_ElapsedTimeEntry[pServerName]["connections"] = {}
    addConnectionData(pCtx, pLogDate, pLogTime, pJobId, pServerName, pConnection, pSizeTransferred)

    return

def addConnectionData(pCtx, pLogDate, pLogTime, pJobId, pServerName, pConnection, pSizeTransferred):
    l_ElapsedTimeEntry = pCtx["ElapsedTimeData"]["jobIds"][pJobId]["servers"][pServerName]["connections"]

    l_ElapsedTimeEntry[pConnection] = {}
    l_ElapsedTimeEntry[pConnection]["StartDateTime"] = (pLogDate, pLogTime)
    l_ElapsedTimeEntry[pConnection]["EndDateTime"] = (pLogDate, pLogTime)
    l_ElapsedTimeEntry[pConnection]["SizeTransferred"] = pSizeTransferred

    return


#
# Routines to handle a given line of output from a console log
#

# NOTE: Handles aren't always requested 'everywhere', so we don't search for this entry anymore...
def GetHandle(pCtx, pData, *pArgs):
    pServerName, pLogDate, pLogTime, pHostName, pConnection, pConnectionIP, pLVUuid, pJobId, pJobStepId, pTag, pNumContrib, pContribs, pHandle = pArgs[0]
    l_GetHandleEntry = pData["Handles"][pHandle]
    # l_GetHandleEntry["LogDate"] = pLogDate
    # l_GetHandleEntry["LogTime"] = pLogTime
    l_GetHandleEntry["JobId"] = pJobId
    l_GetHandleEntry["JobStepId"] = pJobStepId
    l_GetHandleEntry["Tag"] = pTag
    l_GetHandleEntry["NumContrib"] = pNumContrib
    l_GetHandleEntry["Contribs"] = pContribs

    return

def FileCompletion(pCtx, pData, *pArgs):
    pServerName, pLogDate, pLogTime, pFileName, pConnection, pConnectionIP, pLVUuid, pHandle, pContribId, pSourceIndex, pStatus, pTransferType, pTransferSize, pReadCount, pReadTime, pWriteCount, pWriteTime = pArgs[0]

    # Add data to the appropriate file entry
    if "Files" not in pData["Handles"][pHandle]["Connections"][pConnection]["LVUuids"][pLVUuid]["ContribIds"][pContribId]:
        pData["Handles"][pHandle]["Connections"][pConnection]["LVUuids"][pLVUuid]["ContribIds"][pContribId]["Files"] = {}
    pData["Handles"][pHandle]["Connections"][pConnection]["LVUuids"][pLVUuid]["ContribIds"][pContribId]["Files"][pFileName] = {}
    l_FileEntry = pData["Handles"][pHandle]["Connections"][pConnection]["LVUuids"][pLVUuid]["ContribIds"][pContribId]["Files"][pFileName]
    l_FileEntry["LogDate"] = pLogDate
    l_FileEntry["LogTime"] = pLogTime
    l_FileEntry["SourceIndex"] = int(pSourceIndex)
    l_FileEntry["Status"] = pStatus
    l_FileEntry["TransferType"] = pTransferType
    l_FileEntry["TransferSize"] = int(pTransferSize)
    l_FileEntry["ReadCount"] = int(pReadCount)
    l_FileEntry["ReadTime"] = float(pReadTime)
    l_FileEntry["WriteCount"] = int(pWriteCount)
    l_FileEntry["WriteTime"] = float(pWriteTime)

    return

def ContribIdCompletion(pCtx, pData, *pArgs):
    pServerName, pLogDate, pLogTime, pContribId, pConnection, pConnectionIP, pLVUuid, pHandle, pStatus, pDummy, pSizeTransferred, pProcessingTime = pArgs[0]

    # Add data to the appropriate contribid entry
    l_ContribIdEntry = pData["Handles"][pHandle]["Connections"][pConnection]["LVUuids"][pLVUuid]["ContribIds"][pContribId]
    l_ContribIdEntry["LogDate"] = pLogDate
    l_ContribIdEntry["LogTime"] = pLogTime
    l_ContribIdEntry["Status"] = pStatus
    if pSizeTransferred != None:
        l_ContribIdEntry["SizeTransferred"] = pSizeTransferred
    else:
        l_ContribIdEntry["SizeTransferred"] = 0
        l_FileEntry = pData["Handles"][pHandle]["Connections"][pConnection]["LVUuids"][pLVUuid]["ContribIds"][pContribId]["Files"]
        for l_FileData in l_FileEntry.values():
            l_ContribIdEntry["SizeTransferred"] += l_FileData["TransferSize"]
    l_ContribIdEntry["ProcessingTime"] = pProcessingTime

    # If necessary, add to the elapsed time data
    l_ElapsedTimeEntry = pCtx["ElapsedTimeData"]
    if "JobId" in pData["Handles"][pHandle]["Connections"][pConnection]["LVUuids"][pLVUuid]["ContribIds"][pContribId]:
        l_JobId = pData["Handles"][pHandle]["Connections"][pConnection]["LVUuids"][pLVUuid]["ContribIds"][pContribId]["JobId"]

        if cmn.compareTimes((pLogDate, pLogTime), l_ElapsedTimeEntry["jobIds"][l_JobId]["EndDateTime"]) == 1:
            l_ElapsedTimeEntry["jobIds"][l_JobId]["EndDateTime"] = (pLogDate, pLogTime)
        if cmn.compareTimes((pLogDate, pLogTime), l_ElapsedTimeEntry["jobIds"][l_JobId]["servers"][pServerName]["EndDateTime"]) == 1:
            l_ElapsedTimeEntry["jobIds"][l_JobId]["servers"][pServerName]["EndDateTime"] = (pLogDate, pLogTime)
        if cmn.compareTimes((pLogDate, pLogTime), l_ElapsedTimeEntry["jobIds"][l_JobId]["servers"][pServerName]["connections"][pConnection]["EndDateTime"]) == 1:
            l_ElapsedTimeEntry["jobIds"][l_JobId]["servers"][pServerName]["connections"][pConnection]["EndDateTime"] = (pLogDate, pLogTime)

        l_ElapsedTimeEntry["jobIds"][l_JobId]["SizeTransferred"] += l_ContribIdEntry["SizeTransferred"]
        l_ElapsedTimeEntry["jobIds"][l_JobId]["servers"][pServerName]["SizeTransferred"] += l_ContribIdEntry["SizeTransferred"]
        l_ElapsedTimeEntry["jobIds"][l_JobId]["servers"][pServerName]["connections"][pConnection]["SizeTransferred"] += l_ContribIdEntry["SizeTransferred"]
    else:
        print "JobId was not found for handle %d, connection %s, LVUuid %s, contribid %d.  Related transfer rate(s) will not be accurate."

    return

def HandleCompletion(pCtx, pData, *pArgs):
    pServerName, pLogDate, pLogTime, pHandle, pConnection, pConnectionIP, pLVUuid, pStatus = pArgs[0]

    # Add data to the appropriate handle entry
    l_HandleEntry = pData["Handles"][pHandle]
    l_HandleEntry["LogDate"] = pLogDate
    l_HandleEntry["LogTime"] = pLogTime
    l_HandleEntry["Status"] = pStatus

    return

def StartTransfer(pCtx, pData, *pArgs):
    pServerName, pLogDate, pLogTime, pConnection, pConnectionIP, pLVUuid, pHostName, pJobId, pJobStepId, pHandle, pContribId, pRestart = pArgs[0]

    # Add jobid and jobstepid to the appropriate handle entry
    l_GetHandleEntry = pData["Handles"][pHandle]
    l_GetHandleEntry["JobId"] = pJobId
    l_GetHandleEntry["JobStepId"] = pJobStepId

    # Add data to the appropriate start transfer entry
    l_StartTransferEntry = pData["Handles"][pHandle]["Connections"][pConnection]["LVUuids"][pLVUuid]["ContribIds"][pContribId]
    l_StartTransferEntry["LogDate"] = pLogDate
    l_StartTransferEntry["LogTime"] = pLogTime
    l_StartTransferEntry["JobId"] = pJobId
    l_StartTransferEntry["JobStepId"] = pJobStepId
    l_StartTransferEntry["Restart"] = pRestart

    # If necessary, add to the elapsed time data
    l_ElapsedTimeEntry = pCtx["ElapsedTimeData"]
    l_SizeTransferred = 0
    if pJobId not in l_ElapsedTimeEntry["jobIds"]:
        addJobIdData(pCtx, pLogDate, pLogTime, pJobId, pServerName, pConnection, l_SizeTransferred)
    else:
        if cmn.compareTimes((pLogDate,pLogTime), l_ElapsedTimeEntry["jobIds"][pJobId]["StartDateTime"]) == -1:
            l_ElapsedTimeEntry["jobIds"][pJobId]["StartDateTime"] = (pLogDate,pLogTime)
        if pServerName not in l_ElapsedTimeEntry["jobIds"][pJobId]["servers"]:
            addServerData(pCtx, pLogDate, pLogTime, pJobId, pServerName, pConnection, l_SizeTransferred)
        else:
            if cmn.compareTimes((pLogDate, pLogTime), l_ElapsedTimeEntry["jobIds"][pJobId]["servers"][pServerName]["StartDateTime"]) == -1:
                l_ElapsedTimeEntry["jobIds"][pJobId]["servers"][pServerName]["StartDateTime"] = (pLogDate, pLogTime)
            if pConnection not in l_ElapsedTimeEntry["jobIds"][pJobId]["servers"][pServerName]["connections"]:
                addConnectionData(pCtx, pLogDate, pLogTime, pJobId, pServerName, pConnection, l_SizeTransferred)
            else:
                if cmn.compareTimes((pLogDate, pLogTime), l_ElapsedTimeEntry["jobIds"][pJobId]["servers"][pServerName]["connections"][pConnection]["StartDateTime"]) == -1:
                    l_ElapsedTimeEntry["jobIds"][pJobId]["servers"][pServerName]["connections"][pConnection]["StartDateTime"] = (pLogDate, pLogTime)

    return

def StartDumpWorkQueueMgr(pCtx, pData, *pArgs):
    pServerName, pLineData = pArgs[0]
    if pCtx["WORK_QUEUE_MGR_DATA"] == None:
        pCtx["WORK_QUEUE_MGR_DATA"] = []
    pCtx["WORK_QUEUE_MGR_DATA"].append(pLineData[:-1])

    return

def EndDumpWorkQueueMgr(pCtx, pData, *pArgs):
    pServerName, pLineData, pLogDate, pLogTime = pArgs[0]
    StartDumpWorkQueueMgr(pCtx, pData, (pServerName, pLineData,))
    pCtx["WORK_QUEUE_MGR_DATA"].append("")

    l_DumpWorkQueueMgrEntry = pData["WorkQueueMgr"]
    l_DumpWorkQueueMgrEntry[pLogTime] = copy.deepcopy(pCtx["WORK_QUEUE_MGR_DATA"])
    pCtx["WORK_QUEUE_MGR_DATA"] = None

    return

def Error(pCtx, pData, *pArgs):
    pServerName, pLogDate, pLogTime, pErrorData = pArgs[0]
    l_ErrorEntry = pData["Errors"]
    l_ErrorEntry[pLogTime] = pErrorData

    return

def Warning(pCtx, pData, *pArgs):
    pServerName, pLogDate, pLogTime, pErrorData = pArgs[0]
    l_ErrorEntry = pData["Warnings"]
    l_ErrorEntry[pLogTime] = pErrorData

    return

Handle = None
Connection = None
ConnectionIP = None
LVUuid = None
ContribId = None

# KEYS - Tuple of tuples, (key, data type)
KEYS = (("Handle",int), ("Connection",str), ("ConnectionIP",str), ("LVUuid",str), ("ContribId",int))

# SEARCHES - Tuple of tuples, (RegEx expression, tuple of group(i) for each key value (0 indicates not available), data types for each group(i), procedure to process parsed data)
SEARCHES = (
#    (re.compile("(\d+-\d+-\d+)\s+(\d+:\d+:\d+.\d+).*getHandle:\s+hostname\s+([A-Za-z0-9]+),\s+LVKey\(([a-z0-9.]+)\s+\(([0-9.]+)\),([a-z0-9-]+)\),\s+job\((\d+),(\d+)\),\s+tag\s+(\d+),\s+numcontrib\s+(\d+),\s+contrib\s+(\([0-9,]\))\s+->\s+handle\s+(\d+)"),
#     (12, 4, 5, 6, 0),
#     (str, str, str, str, str, str, int, int, int, int, str, int,),
#     GetHandle),
    (re.compile("(\d+-\d+-\d+)\s+(\d+:\d+:\d+.\d+).*msgin\_starttransfer\s+\(1\):\s+Start\s+processing\s+LVKey\(([a-z0-9.]+)\s+\(([0-9.]+)\),([a-z0-9-]+)\),\s+hostname\s+([A-Za-z0-9]+),\s+jobid\s+(\d+),\s+jobstepid\s+(\d+),\s+handle\s+(\d+),\s+contribid\s+(\d+),\s+restart=(true|false)"),
     (9, 3, 4, 5, 10),
     (str, str, str, str, str, str, int, int, int, int, str,),
     StartTransfer),
    (re.compile("(\d+-\d+-\d+)\s+(\d+:\d+:\d+.\d+).*->bbproxy:\s+Transfer\s+completed\s+for\s+file\s+([A-Za-z0-9/._-]+),\s+LVKey\(([a-z0-9.]+)\s+\(([0-9.]+)\),([a-z0-9-]+)\),\s+handle\s+(\d+),\s+contribid\s+(\d+),\s+sourceindex\s+(\d+),\s+file\s+status\s+([A-Z_]+),\s+transfer\s+type\s+([A-Za-z_]+),\s+size\s+transferred\s+is\s+(\d+)\s+bytes,\s+read\s+count/cumulative\s+time\s+(\d+)/([0-9.]+)\s+seconds,\s+write\s+count/cumulative\s+time\s+(\d+)/([0-9.]+)\s+seconds"),
     (7, 4, 5, 6, 8),
     (str, str, str, str, str, str, int, int, int, str, str, int, int, float, int, float,),
     FileCompletion),
    (re.compile("(\d+-\d+-\d+)\s+(\d+:\d+:\d+.\d+).*->bbproxy:\s+Transfer\s+completed\s+for\s+contribid\s+(\d+),\s+LVKey\(([a-z0-9.]+)\s+\(([0-9.]+)\),([a-z0-9-]+)\),\s+handle\s+(\d+),\s+status\s+([A-Z_]+),\s+(total\s+size\s+transferred\s+([0-9.]+),\s+)*total\s+processing\s+time\s+([0-9.]+)\s+seconds"),
     (7, 4, 5, 6, 3),
     (str, str, int, str, str, str, int, str, str, int, float,),
     ContribIdCompletion),
    (re.compile("(\d+-\d+-\d+)\s+(\d+:\d+:\d+.\d+).*->bbproxy:\s+Transfer\s+completed\s+for\s+handle\s+(\d+),\s+LVKey\(([a-z0-9.]+)\s+\(([0-9.]+)\),([a-z0-9-]+)\),\s+status\s+([A-Z_]+)"),
     (3, 4, 5, 6, 0),
     (str, str, int, str, str, str, str,),
     HandleCompletion),
    (re.compile("(\d+-\d+-\d+)\s+(\d+:\d+:\d+.\d+).*bb::error\s+\|\s+(.*)"),
     (0, 0, 0, 0, 0),
     (str, str, str,),
     Error),
    (re.compile("(\d+-\d+-\d+)\s+(\d+:\d+:\d+.\d+).*bb::warning\s+\|\s+(.*)"),
     (0, 0, 0, 0, 0),
     (str, str, str,),
     Warning),
    (re.compile("(.*>>>>>\s+Start:\s+WRKQMGR\s+Work\s+Queue\s+Mgr\s+\(Not\s+an\s+error\s+-\s+Timer\s+Interval\)\s+<<<<<)"),
     (0, 0, 0, 0, 0),
     (str,),
     StartDumpWorkQueueMgr),
    (re.compile("((\d+-\d+-\d+)\s+(\d+:\d+:\d+.\d+).*>>>>>\s+End:\s+WRKQMGR\s+Work\s+Queue\s+Mgr\s+\(Not\s+an\s+error\s+-\s+Timer\s+Interval\)\s+<<<<<)"),
     (0, 0, 0, 0, 0),
     (str, str, str,),
     EndDumpWorkQueueMgr),
)

OLDLOGS = re.compile("oldlogs")
TRAILING_LOGNUMBER = re.compile("\d+\.log\d+")

WORK_QUEUE_MGR_DATA = re.compile("Throttle\s+Mode:|Last\s+Queue\s+Processed:|Async\s+Seq#:|Number\s+of\s+Workqueue\s+Entries:|LVKey\(None,[f-]+\),\s+Job\s+\d+|LVKey\([a-z0-9.]+\s+\([0-9.]+\),[a-z0-9-]+\),\s+Job\s+\d+")

# Establishes environmental values in the context, overriding defaults with command line options
def getOptions(pCtx, pArgs):
    # \todo Input/verification of args needs to be beefed up...

    # Set the default values
    pCtx["ROOTDIR"] = "."
    pCtx["OUTPUT_DIRECTORY_NAME"] = "Analysis"
    pCtx["PICKLE_FILENAME"] = "ConsoleData.pickle"
    pCtx["NAME_PATTERN"] = ("console.*", re.compile("console.*"))
    pCtx["INPUT_SERVER_NAME"] = None
    pCtx["ALL_SERVER_NAMES_PRIMED"] = False
    pCtx["PRINT_PICKLED_RESULTS"] = False
    pCtx["SAVE_PICKLED_RESULTS"] = True

    # Process the input args
    if len(pArgs):
        if len(pArgs) >= 2:
            pCtx["ROOTDIR"] = pArgs[1]
            if len(pArgs) >= 3:
                pCtx["NAME_PATTERN"] = (pArgs[2], re.compile(pArgs[2]))
                if len(pArgs) >= 4:
                    pCtx["INPUT_SERVER_NAME"] = pArgs[3]


    # Normalize the input root path name
    pCtx["ROOTDIR"] = os.path.abspath(os.path.normpath(pCtx["ROOTDIR"]))
    pCtx["OUTPUT_DIRECTORY"] = os.path.join(pCtx["ROOTDIR"], pCtx["OUTPUT_DIRECTORY_NAME"])
    pCtx["WORK_QUEUE_MGR_DATA"] = None

    # Print out the environment
    print "Environmental data"
    pprint.pprint(pCtx)
    print

    return

# Return the server name from the path
def getServerName(pCtx, pPath):
    l_ServerName = None
    if pCtx["INPUT_SERVER_NAME"]:
        l_ServerName = pCtx["INPUT_SERVER_NAME"]
    else:
        l_Path = [pPath,pPath]
        while (l_Path[0] != pCtx["ROOTDIR"]):
            l_Path = os.path.split(l_Path[0])
            l_ServerName = l_Path[1]

    return l_ServerName

# Parse/process a given line of output
def processLine(pCtx, pServerName, pData, pLine):
    l_DoProcessLine = False
    l_ArgsIsEntireLine = False

    # Search for an interesting line...
    for l_Search in SEARCHES:
        l_Success = l_Search[0].search(pLine)
        if l_Success:
            break

     # Found an interesting line...
    if l_Success:
        l_DoProcessLine = True
        # Set the key values from the parsed data
        i = 0
        for (l_VariableName, l_Func) in KEYS:
            l_Index = l_Search[1][i]
            if l_Index:
                globals()[l_VariableName] = l_Func(l_Success.group(l_Index))
            else:
                globals()[l_VariableName] = None
            i += 1

        # Prime any necessary data based on the key values
        if Handle != None:
            if Handle not in pData["Handles"]:
                pData["Handles"][Handle] = {}
            if "Connections" not in pData["Handles"][Handle]:
                pData["Handles"][Handle]["Connections"] = {}
            if Connection != None:
                if Connection not in pData["Handles"][Handle]["Connections"]:
                    pData["Handles"][Handle]["Connections"][Connection] = {}
                if ConnectionIP != None:
                    pData["Handles"][Handle]["Connections"][Connection]["ConnectionIP"] = ConnectionIP
                if LVUuid != None:
                    if "LVUuids" not in pData["Handles"][Handle]["Connections"][Connection]:
                        pData["Handles"][Handle]["Connections"][Connection]["LVUuids"] = {}
                    if LVUuid not in pData["Handles"][Handle]["Connections"][Connection]["LVUuids"]:
                        pData["Handles"][Handle]["Connections"][Connection]["LVUuids"][LVUuid] = {}
                    if "ContribIds" not in pData["Handles"][Handle]["Connections"][Connection]["LVUuids"][LVUuid]:
                        pData["Handles"][Handle]["Connections"][Connection]["LVUuids"][LVUuid]["ContribIds"] = {}
                    if ContribId != None:
                        if ContribId not in pData["Handles"][Handle]["Connections"][Connection]["LVUuids"][LVUuid]["ContribIds"]:
                            pData["Handles"][Handle]["Connections"][Connection]["LVUuids"][LVUuid]["ContribIds"][ContribId] = {}
    elif pCtx["WORK_QUEUE_MGR_DATA"]:
        l_Success = WORK_QUEUE_MGR_DATA.search(pLine)
        if l_Success:
            # WorkQueueMgr dump in progress...  Treat as 'StartDumpWorkQueueMgr'
            l_Search = SEARCHES[6]
            l_DoProcessLine = True
            l_ArgsIsEntireLine = True

    if l_DoProcessLine:
        # Build the argument list
        l_Args = [pServerName]
        if not l_ArgsIsEntireLine:
            for i in xrange(len(l_Search[2])):
                if l_Success.group(i + 1) != None:
                    l_Args.append(l_Search[2][i](l_Success.group(i + 1)))
                else:
                    l_Args.append(None)
# NOTE: Replace the above with the commented out line when we no longer process contribid complete messages without a transfer size
#       Make similar change to the SEARCH definition above...
#            l_Args = [l_Search[2][i](l_Success.group(i + 1)) for i in xrange(len(l_Search[2]))]
        else:
            l_Args.append(pLine)
        # Invoke the procedure to handle this parsed data
        l_Search[3](pCtx, pData, l_Args)

# Process a console log
def processFile(pCtx, *pArgs):
    pServerName, pData, pFullFileName = pArgs[0]

    print "Start: Processing %s as a console log..." % (pFullFileName)
    with open(pFullFileName) as l_File:
        while (True):
            l_Lines = l_File.readlines(64 * 1024)
            if (l_Lines):
                for l_Line in l_Lines:
                    processLine(pCtx, pServerName, pData, l_Line)
            else:
                break
    # NOTE: If we split in the middle of a work queue mgr dump, we lose that data...
    pCtx["WORK_QUEUE_MGR_DATA"] = None
    print "  End: Processing %s as a console log..." % (pFullFileName)

    return

def processFiles(pCtx):
    l_Files = pCtx["FilesToProcess"].keys()
    l_Files.sort()

    l_FirstPass = []
    l_SecondPass = []
    l_ThirdPass = []
    for l_File in l_Files:
        l_Success = OLDLOGS.search(pCtx["FilesToProcess"][l_File][2])
        if l_Success:
            l_Success = TRAILING_LOGNUMBER.search(pCtx["FilesToProcess"][l_File][2])
            if l_Success:
                l_FirstPass.append(pCtx["FilesToProcess"][l_File])
            else:
                l_SecondPass.append(pCtx["FilesToProcess"][l_File])
        else:
            l_ThirdPass.append(pCtx["FilesToProcess"][l_File])

    for l_Pass in (l_FirstPass, l_SecondPass, l_ThirdPass):
        for l_FileData in l_Pass:
            processFile(pCtx, l_FileData)
    print

    return

# Find console logs for a given path
def findFiles(pCtx, pServerName, pData, pPath, pFiles):
    for l_FileName in pFiles:
        l_FullFileName = os.path.join(pPath,l_FileName)
        if os.path.isfile(l_FullFileName) and (not os.path.islink(l_FullFileName)):
            l_Success = pCtx["NAME_PATTERN"][1].search(l_FileName)
            if l_Success:
                print "File %s will be processed as a console log..." % (l_FullFileName)
                pCtx["FilesToProcess"][l_FullFileName] = (pServerName, pData, l_FullFileName)
            else:
                print "%sSkipping file %s, does not match file pattern..." % (4*" ", l_FullFileName)
        else:
            print "%sSkipping file %s, not a file or is a link..." % (4*" ", l_FullFileName)

    return

# Walk the root path, processing subdirectories/files along the way
def walkPaths(pCtx, pPath):
    l_Data = pCtx["ServerData"]
    for l_Path, l_SubDirs, l_Files in os.walk(pPath):
        if not pCtx["ALL_SERVER_NAMES_PRIMED"]:
            if pCtx["INPUT_SERVER_NAME"] == None:
                for l_SubDir in l_SubDirs:
                    if l_SubDir != pCtx["OUTPUT_DIRECTORY_NAME"]:
                        l_Data[l_SubDir] = {}
                        l_Data[l_SubDir]["Errors"] = {}
                        l_Data[l_SubDir]["Warnings"] = {}
                        l_Data[l_SubDir]["Handles"] = {}
                        l_Data[l_SubDir]["WorkQueueMgr"] = {}
            else:
                l_Data[pCtx["INPUT_SERVER_NAME"]] = {}
                l_Data[pCtx["INPUT_SERVER_NAME"]]["Handles"] = {}
                l_Data[pCtx["INPUT_SERVER_NAME"]]["WorkQueueMgr"] = {}
            pCtx["ALL_SERVER_NAMES_PRIMED"] = True

        if l_Files:
            l_ServerName = getServerName(pCtx, l_Path)
            if l_ServerName != pCtx["OUTPUT_DIRECTORY_NAME"]:
                if l_ServerName:
                    findFiles(pCtx, l_ServerName, l_Data[l_ServerName], l_Path, l_Files)
    print

    return

# Main routine
def main(*pArgs):
    l_Ctx = {}                    # Environmental context
    l_Ctx["FilesToProcess"] = {}
    l_Ctx["ServerData"] = {}      # Server data is stored here
    l_Ctx["ElapsedTimeData"] = {} # Start/end time, transfer sizes stored here by jobid/server/connection
    l_Ctx["ElapsedTimeData"]["jobIds"] = {}

    # Establish the context
    getOptions(l_Ctx, pArgs[0])
    # Ensure that the output directory exists...
    cmn.ensure(l_Ctx["OUTPUT_DIRECTORY"])

    # Walk the paths processing data along the way, starting with the input root directory
    walkPaths(l_Ctx, l_Ctx["ROOTDIR"])

    # Process the files
    processFiles(l_Ctx)

    if l_Ctx["PRINT_PICKLED_RESULTS"]:
        cmn.printFormattedData(l_Ctx, l_Ctx["ServerData"])
        cmn.printFormattedData(l_Ctx, l_Ctx["ElapsedTimeData"])

    if l_Ctx["SAVE_PICKLED_RESULTS"]:
        cmn.saveData(l_Ctx)
    else:
        print "Results not saved"

    return


if __name__ == '__main__':
    main(sys.argv)