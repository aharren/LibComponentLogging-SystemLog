

# LibComponentLogging-SystemLog

[http://0xc0.de/LibComponentLogging](http://0xc0.de/LibComponentLogging)    
[http://github.com/aharren/LibComponentLogging-SystemLog](http://github.com/aharren/LibComponentLogging-SystemLog)


## Overview

LibComponentLogging-SystemLog is a logging class for Objective-C (Mac OS X
and iPhone OS) which sends log messages to the Apple System Log facility (ASL).
See man pages of asl, syslog, and syslogd for details about ASL.

LCLSystemLog can be used as a logging back-end for LibComponentLogging, but it
is also useable as a standalone logging class without the Core files of
LibComponentLogging.

With ASL, log messages are stored as structured messages in a data store.
The syslog utility or the Console application can be used to retrieve messages
from this data store, e.g.

    syslog -F '$(Time) $(Sender)[$(PID):$(Thread)] $(Level0) $(Message)
        ($(Facility):$(File):$(Line))' -T utc -k Level0 -k Sender eq Example

retrieves all messages from the data store where the value associated with
the 'Sender' key (the identifier of an application) is equal to 'Example' and
where a value for the 'Level0' key exists. The key 'Level0' is used by
LCLSystemLog to store the log level in addition to a mapped ASL priority
level ('Level' key). All retrieved messages will be printed by using the UTC
time format and the display format specified via -F. Example output:

    2009.02.21 11:37:08 UTC Example[6717:10b] D Message 1 (example.f1:main.m:28)
    2009.02.21 11:37:08 UTC Example[6717:10b] C Message 2 (example.f2:main.m:32)
    2009.02.21 11:37:08 UTC Example[6717:10b] I Message 3 (example.f3:main.m:36)

By default, the default data store will only save log messages which have
an ASL priority level between 'Emergency' and 'Notice' (level 0 to 5). Log
messages with level 'Info' (level 6) or 'Debug' (level 7) will not be written
to the data store. The command line

    sudo syslog -c syslog -d

can be used to tell syslogd to store messages up to priority level 'Debug'.

Alternatively, LCLSystemLog can be configured to use only ASL priority levels
up to a specific last level, e.g. 'Notice'. All log messages with a higher level
will be mapped to the configured last level, e.g. 'Debug' messages will be
logged with the ASL level 'Notice' while the 'Level0' field will still contain
the level information 'Debug'.


## Usage

Before you start, copy the LCLSystemLog.h and .m file to your project and create
a LCLSystemLogConfig.h configuration file (based on the packaged template file).

Then, import the LCLSystemLog.h in your source files or in your prefix header
file if you are using LCLSystemLog as a standalone logging class, or add an
import to your lcl_config_logger.h file if you are using the class as a logging
back-end for LibComponentLogging.

In case you are using the LCLSystemLog class with LibComponentLogging, you can
simply start logging to ASL by using the standard logging macro from
LibComponentLogging, e.g.

    lcl_log(lcl_cMyComponent, lcl_vError, @"message ...");

If you are using the class as a standalone logger, you can simply call one of
the log... methods from the LCLSystemLog class, e.g.

    [LCLSystemLog logWithIdentifier:"MyComponent" level:1 ... format:@"message ...", ...];

or you can wrap these calls into your own logging macros.


## Repository Branches

The Git repository contains the following branches:

* [master](http://github.com/aharren/LibComponentLogging-SystemLog/tree/master):
  The *master* branch contains stable builds of the main logging code which are
  tagged with version numbers.

* [devel](http://github.com/aharren/LibComponentLogging-SystemLog/tree/devel):
  The *devel* branch is the development branch for the logging code which
  contains an Xcode project with dependent code, e.g. the Core files of
  LibComponentLogging, and unit tests. The code in this branch is not stable.


## Related Repositories

The following Git repositories are related to this repository: 

* [http://github.com/aharren/LibComponentLogging-Core](http://github.com/aharren/LibComponentLogging-Core):
  Core files of LibComponentLogging.


## Copyright and License

Copyright (c) 2008-2010 Arne Harren <ah@0xc0.de>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

