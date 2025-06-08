/*
    BoincTasks-M to show and control one or multiple BOINC clients.
    Copyright (C) 2024-now  eFMer

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

import 'package:flutter/material.dart';

// BoincTasks
const cBoincTasksM = "BoincTasks-M";

// BOINC
const cBoincReply = "boinc_gui_rpc_reply";

// system
const cTimeoutGeneralConnection = 240;  // timeout of all (socket) connections (sec)
const cTimeoutSocket = 30;              // timeout of a single socket (sec)


const cFileNameComputers = "computers.xml";
const cFileNameSettings  = "settings.json";
const cFileNameColors    = "colors.json";
const cFileNameSort      = "sort.json";

const cFileNameHeaderComputersWidth = "header_computers_width";
const cFileNameHeaderMessagesWidth   = "header_messages_width";
const cFileNameHeaderProjectsWidth  = "header_projects_width";
const cFileNameHeaderTasksWidth     = "header_tasks_width";
const cFileNameHeaderTransfersWidth = "header_transfers_width";

const cComputerEnabled    = "enabled";
const cComputerGroup      = "group";
const cComputerName       = "name";
const cComputerIp         = "ip";
const cComputerPort       = "port";
const cComputerPassword   = "password";
const cComputerStatus     = "status";
const cComputerConnected  = "connected";
const cComputerBoinc      = "boinc";
const cComputerPlatform   = "platform";

const txtTasksCommandSuspended= "Suspend";
const txtTasksCommandResume   = "Resume";
const txtTasksCommandAborted  = "Abort";

const cComputerConnectedNot = '0';
const cComputerConnectedAuthenticatedNot = '1';
const cComputerConnectedAuthenticated = '2';

var cComputerNewName  = "${String.fromCharCode(127)}toAdd${String.fromCharCode(24)}";  // something you can't make with a keyboard.

const cRpcRequest1 = "<boinc_gui_rpc_request>\n";
const cRpcRequest2 = "</boinc_gui_rpc_request>\n\u0003";

const cTabComputers = "10";
const cTabProjects = "11";
const cTabTasks = "12";
const cTabTransfers = "13";
const cTabMessages = "14";
const cTabNotices = "15";
const cAdjustWidth  = '100';

const cTypeFilter = 0;
const cTypeFilterWuArr = 1;
const cTypeFilterWU = 2;
const cTypeComputer = 3;
const cTypeProject = 4;
const cTypeResult = 5;
const cTypeTransfer = 6;
const cTypeMessage = 7;

const cTextFilter = " Filter ";
const cFilterArrayPosId = 0;
const cFilterArrayPosCount = 1;
const cFilterArrayPosElapsed = 5;
const cFilterArrayPosCpu = 6;
const cFilterArrayPosProgress = 7;
const cFilterArrayPosStatus = 8;

const cHeaderTab        = "tab";

const cTasksPosType     = 0;
const cTasksPosApp      = 1;
const cTasksPosProject  = 2;
const cTasksPosName     = 3;
const cTasksPosElapsed  = 4;
const cTasksPosCpu      = 5;
const cTasksPosProgress = 6;
const cTasksPosStatus   = 7;
const cTasksPosFilter   = 8;

const cTasksProject     = "project";
const cTasksWu          = "wu";

const cProjectsPosProject = 1;
const cProjectsPosStatus  = 3;
const cProjectsProject    = "project";

const cTransfersPosProject  = 1;
const cTransfersPosFile     = 2;
const cTransfersPosSize     = 3;
const cTransfersPosElapsed  = 4;
const cTransfersPosSpeed    = 5;
const cTransfersPosProgress = 6;
const cTransfersPosStatus   = 7;

const cTransfersProject   = "project";
const cTransfersFile      = "file";

const cSettingsRefresh    = "refresh_rate";
const cSettingsDebug      = "debug_mode";

const cAuthenticate1  = 0;
const cAuthenticate2  = 1;
const cHostInfo       = 2;
const cState          = 3;
const cStatusTask     = 4;
const cTasks          = 5;
const cProjects       = 6;
const cProjectsList   = 7;
const cMessages       = 8;
const cTransfers      = 9; 
const cSendCommand    = 10;

const indexColorTasksSuspendedBack       = 0;
const indexColorTasksRunningBack         = 1;
const indexColorTasksDownloadingBack     = 2;
const indexColorTasksReadyToStartBack    = 3;
const indexColorTasksComputationErrorBack= 4;
const indexColorTasksUploadingBack       = 5;
const indexColorTasksReadyToReportBack   = 6;
const indexColorTasksWaitingToRunBack    = 7;
const indexColorTasksSuspendedByUserBack = 8;
const indexColorTasksAbortedBack         = 9;

const defColorTasksSuspendedBack      = Color.fromARGB(71, 16, 101, 124);
const cColorTasksSuspendedBack        = "Tasks_suspended_back";
const defColorTasksRunningBack        = Color.fromARGB(255, 2, 255, 107);
const cColorTasksRunningBack          = "Tasks_running_back";
const defColorTasksDownloadingBack    = Color.fromARGB(255, 255, 242, 5);
const cColorTasksDownloadingBack      = "Tasks_downloading_back";
const defColorTasksReadyToStartBack   = Color.fromARGB(255, 162, 220, 244);
const cColorTasksReadyToStartBack     = "Tasks_ready_to_start_back";
const defColorTasksComputationErrorBack= Color.fromARGB(255, 255, 0, 0);
const cColorTasksComputationErrorBack  = "Tasks_computation_error_back";
const defColorTasksUploadingBack      = Color.fromARGB(255, 187, 189, 189);
const cColorTasksUploadingBack        = "Tasks_uploading_back";
const defColorTasksReadyToReportBack  = Color.fromARGB(255, 125, 255, 3);
const cColorTasksReadyToReportBack    = "Tasks_ready_to_teport_back";
const defColorTasksWaitingToRunBack   =  Color.fromARGB(70, 13, 150, 0);
const cColorTasksWaitingToRunBack     = "Tasks_waiting_to_run_back";
const defColorTasksSuspendedByUserBack=  Color.fromARGB(255, 0, 175, 184);
const cColorTasksSuspendedByUserBack  = "Tasks_suspended_by_user_back";
const defColorTasksAbortedBack        = Color.fromARGB(255, 255, 170, 0);
const cColorTasksAbortedBack          = "Tasks_aborted_back";

// Sort header
const cSortHeaderShort = 0;
const cSortHeaderLong = 1;
// one left open for future use.
const cSortHeaderShortDir = 3;
const cSortHeaderLongDir = 4;

const cSortHeaderComputer = 0;
const cSortHeaderProjects = 1;
const cSortHeaderTasks    = 2;
const cSortHeaderTransfers= 3;
const cSortHeaderMessages = 4;

const cArrowUpShort = "▲";
const cArrowDownShort = "▼";
const cArrowUpLong = "ᐃ";
const cArrowDownLong = "ᐁ";

const cMinHeaderWidth = 50.0;
const cMaxHeaderWidth = 700.0;