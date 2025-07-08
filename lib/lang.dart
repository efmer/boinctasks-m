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

// title

var txtTitleComputers          = "Computers";
var txtTitleProjects           = "Projects";
var txtTitleTasks              = "Tasks";
var txtTitleTransfers          = "Transfers";
var txtTitleMessages           = "Messages";

// general
var txtHeaderComputer         = "Computer";
var txtHeaderProject          = "Project";
var txtHeaderStatus           = "Status";

// computers
var txtComputerHeaderEnabled  = "Enabled";
var txtComputerHeaderGroup    = "Group";
var txtComputerHeaderComputer = "Computer";
var txtComputerHeaderIp       = "Ip";
var txtComputerHeaderPort     = "Port";
var txtComputerHeaderBoinc    = "BOINC";
var txtComputerHeaderPlatform = "Platform";
var txtComputerHeaderPassword = "Password";
var txtComputersDelete        = "Remove the Enabled check and press Delete again";

const txtComputersAdd           = "Add computer";
const txtComputersFind          = "Find computers";

var txtComputerStatusDisabled     = "Disabled";
var txtComputerStatusConnectedA   = "Connected";
var txtComputerStatusConnectedN   = "Password error";
var txtComputerStatusNotConnected = "Not connected";
var xtxtComputerStatusTimeout     = "Timeout";

// find computers
var txtComputersFindTitle         = "Find computers";
var txtComputersFindRationaleTitle= "About location permisson";
var txtComputersFindRationale     = "This application will now ask you for location permission.\n"
                                    "We need location permission to retrieve the local network IP address.\n"
                                    "If you don't give permission, you'll have to find and enter the IP address manually.";
var txtComputersFoundTitle        = "Found computers";
var txtComputersScanStart         = "This may take a few minutes, we will inform you when the scan is ready.";
var txtComputersScanToAdd         = "You can add the following computers to the Computers tab by clicking the Add button.\n\n";
var txtComputersScanRemoved       = "\nThe following computers were found, but they already exist in the Computers tab.\n\n";
var txtComputersScanNothing       = "We found no (new) computers, please read the manual on efmer.com.";
var txtComputerScanInValidIp      = "Invalid IP address";
var txtComputerScanInValidIpLocal = "This is not a local IP address";
var txtComputerScanInValidPort    = "Invalid Port number";
var txtComputerScanInValidName    = "The name is too short";
var txtComputerScanDialogNoIp	    = "\nYou need to add a valid IPV4 address from a network that is accessible.\nFor example: 192.168.0.1\n";

var txtButtonOK                   = "OK";
var txtButtonFind                 = "Find";
var txtButtonCancel               = "Cancel";
var txtButtonAdd                  = "Add";
var txtButtonContinue             = "Continue";
var txtButtonDelete               = "Delete";

// connection status
const txtSocketUndefined = "";
const txtSocketConnectionRefused = "Connection refused";

// projects
var txtProjectHeaderShare   = "Share";
var txtProjectHeaderStatus  = "Status";

var txtProjectsCommandSuspended     = "Suspend";
var txtProjectsCommandResume        = "Resume";
var txtProjectCommandUpdate         = "Update";
var txtProjectCommandNoMoreWork     = "No more work";
var txtProjectCommandAllowMoreWork  = "Allow more work";
const txtProjectCommandAdd          = "Add project";

// Tasks
var txtTasksHeaderApp     = "App";
var txtTasksHeaderName    = "Name";
var txtTasksHeaderElapsed = "Elapsed";
var txtTasksHeaderProgress= "Progress";
var txtTasksHeaderCpu     = "Cpu";

var txtTasksSuspended       = "Suspended";
var txtTasksRunning         = "Running";
var txtTasksDownloading     = "Downloading";
var txtTasksReadyToStart    = "Ready to start";
var txtTasksComputationError= "Computation error";
var txtTasksUploading       = "Uploading";
var txtTasksReadyToReport   = "Ready to report";
var txtTasksWaitingToRun    = "Waiting to run";
var txtTasksSuspendedByUser = "Suspended by user";
var txtTasksAborted         = "Aborted";
var txtTasksHighPriority    = "High p.";
var txtTasksText            = "Text";

var txtTasksDialogAbort     = "Number of tasks to abort:";

// transfers
var txtTransfersHeaderFile      = "File";
var txtTransfersHeaderSize      = "Size";
var txtTransfersHeaderElapsed   = "Elapsed";
var txtTransfersHeaderSpeed     = "Speed";
var txtTransferHeaderProgress   = "Progress";

var txtTransfersCommandRetry    = "Retry";

// messages
var txtMessagesHeaderNr       = "Nr";
var txtMessagesHeaderTime     = "Time";
var txtMessagesHeaderMessage  = "Message";

const txtProperties             = "Properties";

// settings
var txtSettingsRefreshTime    = "Refresh time in seconds";
var txtSettingsDarkMode       = "Dark mode";
var txtSettingsDebugEnabled   = "Enable debug mode";

// add project
var txtComputers              = "Computers";
var txtSelectComputer         = "Select computer";
var txtSelectProject          = "Select project";

var txtNotConnected           = "Not connected or enabled";

// logging
var txtLoggingDialogName      = "Logging";
var txtLoggingErrorDialogName = "Error logging";
var txtLoggingDebugMode       = "Debug logging enabled";
var txtLoggingDebugModeNot    = "Debug logging disabled";
var txtLoggingButtonShare     = "Copy to clipboad & share logging text";
var txtLoggingCopied          = "Logging text copied";
var txtLoggingRefresh         = "Refresh logging";
var txtLoggingClear           = "Clear logging";

// About
var txtAboutDialogName        = "About";
var txtAboutLicence           = "Read the online license";
var txtAboutGithub            = "Click here to request new features,\n or report a bug on GitHub.";
var txtAboutWebsite           = "Visit our website.";

//Graph
var txtGraphAvgHost           = "Host average";
var txtGraphAvgUser           = "User average";
var txtGraphTotHost           = "Host total";
var txtGraphTotUser           = "User total";