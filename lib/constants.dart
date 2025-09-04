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
//const cTimeoutGeneralConnection = 60;  // timeout of all (socket) connections (sec)
//const cTimeoutSocket = 30;              // timeout of a single socket (sec)


const cFileNameComputers = "computers.xml";
const cFileNameSettings  = "settings.json";
const cFileNameSetTab    = "set_tab.json";
const cFileNameColors    = "colors.json";
const cFileNameSort      = "sort.json";
const cFileNameArrange   = "arrange.json";

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
const txtCommandSelectFirst   = "First select and item below";

const cComputerConnectedNot = '0';
const cComputerConnectedAuthenticatedNot = '1';
const cComputerConnectedAuthenticated = '2';

var cComputerNewName  = "${String.fromCharCode(127)}toAdd${String.fromCharCode(24)}";  // something you can't make with a keyboard.

const cRpcRequest1 = "<boinc_gui_rpc_request>\n";
const cRpcRequest2 = "</boinc_gui_rpc_request>\n\u0003";

const cTabComputers = "10";
const cTabProjects  = "11";
const cTabTasks     = "12";
const cTabTransfers = "13";
const cTabMessages  = "14";
const cTabNotices   = "15";
const cTabGraph     = "20";
const cTabAllow     = "30";
const cAdjustWidth  = '100';

const cTypeFilter       = 0;
const cTypeFilterWuArr  = 1;
const cTypeFilterWU     = 2;
const cTypeComputer     = 3;
const cTypeProject      = 4;
const cTypeResult       = 5;
const cTypeResultCollapsed = 6;
const cTypeTransfer     = 7;
const cTypeMessage      = 8;

const cTextFilter = " Filter ";
const cFilterArrayPosId       = 0;
const cFilterArrayPosCount    = 1;
const cFilterArrayPosElapsed  = 5;
const cFilterArrayPosCpu      = 6;
const cFilterArrayPosProgress = 7;
const cFilterArrayPosStatus   = 8;
const cFilterArrayPosTimeLeft = 9;
const cFilterArrayPosDeadline = 10;
const cFilterArrayPosUse      = 11;

const cHeaderTab        = "tab";

const cTasksPosType     = 0;
const cTasksPosApp      = 1;
const cTasksPosProject  = 2;
const cTasksPosName     = 3;
const cTasksPosElapsed  = 4;
const cTasksPosCpu      = 5;
const cTasksPosProgress = 6;
const cTasksPosStatus   = 7;
const cTasksPosTimeLeft = 8;
const cTasksPosDeadline = 9;
const cTasksPosUse      = 10;
const cTasksPosFilter   = 11;

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

const cMessagesPosNr      = 1;
const cMessagesPosProject = 2;
const cMessagesPosTime    = 3;
const cMessagesPosMsg     = 4;
const cMessagesNr         = "Nr";

const cSettingsRefresh        = "refresh_rate";
const cSettingsReconnect      = "reconnect_timeout";
const cSettingsMaxBusy        = "max_busy";
const cSettingsSocketTimeout  = "socket_timeout";
const cSettingsDarkMode       = "dark_mode";
const cSettingsDebug          = "debug_mode";

const cSetTabDeadline         = "deadline";
const cSetTabDeadlineNever    = "never";
const cSetTabOneLine          = "one_line";

const cArrangeTasks           = "arrange_tasks";
const cArrangeTasksEnabled    = "arrange_tasks_enabled";

const cLoggingNormal          = 0;
const cLoggingDebug           = 1;
const cLoggingError           = 2;

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
const cBoincSettings  = 11;
const cGraph          = 12;
const cSendCommand    = 13;

const cNotFound       = "??";

// working colors, switched from main
// numbers must be the same as Main light
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
const indexColorTasksHighPriorityBack    = 10;
const indexColorTasksText                = 11;
const indexColorTasksCollapsed           = 12;

// main colors, for reading, writing and switching from light to dark
// numbers must be the same as above
// light
const indexColorMainTasksSuspendedBack       = 0;
const indexColorMainTasksRunningBack         = 1;
const indexColorMainTasksDownloadingBack     = 2;
const indexColorMainTasksReadyToStartBack    = 3;
const indexColorMainTasksComputationErrorBack= 4;
const indexColorMainTasksUploadingBack       = 5;
const indexColorMainTasksReadyToReportBack   = 6;
const indexColorMainTasksWaitingToRunBack    = 7;
const indexColorMainTasksSuspendedByUserBack = 8;
const indexColorMainTasksAbortedBack         = 9;
const indexColorMainTasksHighPriorityBack    = 10;
const indexColorMainTasksText                = 11;
const indexColorMainTasksCollapsed           = 12;

// dark
const indexColorMainDarkTasksSuspendedBack       = 30;
const indexColorMainDarkTasksRunningBack         = 31;
const indexColorMainDarkTasksDownloadingBack     = 32;
const indexColorMainDarkTasksReadyToStartBack    = 33;
const indexColorMainDarkTasksComputationErrorBack= 34;
const indexColorMainDarkTasksUploadingBack       = 35;
const indexColorMainDarkTasksReadyToReportBack   = 36;
const indexColorMainDarkTasksWaitingToRunBack    = 37;
const indexColorMainDarkTasksSuspendedByUserBack = 38;
const indexColorMainDarkTasksAbortedBack         = 39;
const indexColorMainDarkTasksHighPriorityBack    = 40;
const indexColorMainDarkTasksText                = 41;
const indexColorMainDarkTasksCollapsed           = 42;
const indexColorMainLast                         = 42;    // highest index number

// Light
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
const defColorTasksWaitingToRunBack   = Color.fromARGB(70, 13, 150, 0);
const cColorTasksWaitingToRunBack     = "Tasks_waiting_to_run_back";
const defColorTasksSuspendedByUserBack= Color.fromARGB(255, 0, 175, 184);
const cColorTasksSuspendedByUserBack  = "Tasks_suspended_by_user_back";
const defColorTasksAbortedBack        = Color.fromARGB(255, 255, 170, 0);
const cColorTasksAbortedBack          = "Tasks_aborted_back";
const defColorTasksHighPriority       = Color.from(alpha: 1, red: 0.996, green: 0.431, blue: 0.431);
const cColorTasksHighPriority         = "Tasks_high_priority";
const defColorTasksText               = Color.fromARGB(255, 0, 0, 0);
const cColorTasksText                 = "Text color";
const defColorTasksCollapsed          = Color.fromARGB(255, 128, 127, 127);
const cColorTasksCollapsed            = "Collapsed computer";

// Dark
const defDarkColorTasksSuspendedBack        = Color.fromARGB(70, 119, 143, 150);
const cDarkColorTasksSuspendedBack          = "Dark_tasks_suspended_back";
const defDarkColorTasksRunningBack          = Color.fromARGB(255, 5, 5, 5);
const cDarkColorTasksRunningBack            = "Dark_tasks_running_back";
const defDarkColorTasksDownloadingBack      = Color.fromARGB(255, 138, 131, 7);
const cDarkColorTasksDownloadingBack        = "Dark_tasks_downloading_back";
const defDarkColorTasksReadyToStartBack     = Color.fromARGB(255, 38, 125, 163);
const cDarkColorTasksReadyToStartBack       = "Dark_tasks_ready_to_start_back";
const defDarkColorTasksComputationErrorBack = Color.fromARGB(255, 255, 0, 0);
const cDarkColorTasksComputationErrorBack   = "Dark_tasks_computation_error_back";
const defDarkColorTasksUploadingBack        = Color.fromARGB(255, 65, 83, 83);
const cDarkColorTasksUploadingBack          = "Dark_tasks_uploading_back";
const defDarkColorTasksReadyToReportBack    = Color.fromARGB(255, 91, 150, 35);
const cDarkColorTasksReadyToReportBack      = "Dark_tasks_ready_to_teport_back";
const defDarkColorTasksWaitingToRunBack     = Color.fromARGB(255, 50, 67, 48);
const cDarkColorTasksWaitingToRunBack       = "Dark_tasks_waiting_to_run_back";
const defDarkColorTasksSuspendedByUserBack  = Color.fromARGB(255, 131, 87, 36);
const cDarkColorTasksSuspendedByUserBack    = "Dark_tasks_suspended_by_user_back";
const defDarkColorTasksAbortedBack          = Color.fromARGB(255, 192, 25, 89);
const cDarkColorTasksAbortedBack            = "Dark_tasks_aborted_back";
const defDarkColorTasksHighPriority         = Color.fromARGB(255, 155, 66, 66);
const cDarkColorTasksHighPriority           = "Dark_tasks_high_priority";
const defDarkColorTasksText                 = Color.fromARGB(255, 255, 255, 255);
const cDarkColorTasksText                   = "Dark_text_color";
const defDarkColorTasksCollapsed            = Color.fromARGB(255, 128, 127, 127);
const cDarkColorTasksCollapsed              = "Dark_collapsed";

const cColorStriping                        = "striping";

const cColorStripingNone                    = "striping_none";
const cColorStripingLow                     = "striping_low";
const cColorStripingNormal                  = "striping_normal";
const cColorStripingHigh                    = "striping_high";

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
const cMaxHeaderWidth = 800.0;

const cHeaderNormal = 0;
const cHeaderStatus = 1;
const cHeaderNoPerc = 2;
const cHeaderPerc   = 3;

const cWidthShowButtonsAll2 = 1000;
const cWidthShowButtonsAll = 850;
const cWidthShowButtons = 700;