// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for more information

#pragma once

#define SECURITY_WIN32
#include <WinSock2.h>
#include <windows.h>
#include <iostream>
#include <mutex>

#include <Security.h>
#include <schnlsp.h>

#include <ws2def.h>
#include <mstcpip.h>
#include <ws2tcpip.h>
#include <mfidl.h>
#include <windows.foundation.h>
#include <windows.Storage.streams.h>
#include <sstream>
#include <winrt\base.h>
#include <winrt\Windows.Foundation.h>
#include <winrt\Windows.Foundation.Collections.h>
#include <winrt\windows.system.threading.h>
#include <winrt\Windows.Security.Cryptography.h>
#include <winrt\Windows.Security.Cryptography.Core.h>
#include <winrt\Windows.Security.Credentials.h>
#include <winrt\Windows.Storage.Streams.h>
#define HRESULT_EXCEPTION_BOUNDARY_FUNC catch(...) { auto hr = winrt::to_hresult(); return hr;}
#include "NetworkMediaStreamer.h"
#include "RTSPServerControl.h"
#include "SocketWrapper.h"
#include "RtspSession.h"
#include "RTSPServer.h"
