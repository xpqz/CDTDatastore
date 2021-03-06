//
//  CDTLogging.h
//
//
//  Created by Rhys Short on 01/10/2014.
//
//

#import "CocoaLumberjack.h"

#ifndef _CDTLogging_h
#define _CDTLogging_h

/*

 Macro definitions for custom logger contexts, this allows different parts of CDTDatastore
 to separate its log messages and have different levels.

 Each component should set its log level using a static variable in the name <component>LogLevel
 the macros will then perform correctly at compile time.

 */

#define CDTINDEX_LOG_CONTEXT 10
#define CDTREPLICATION_LOG_CONTEXT 11
#define CDTDATASTORE_LOG_CONTEXT 12
#define CDTDOCUMENT_REVISION_LOG_CONTEXT 13
#define CDTTD_REMOTE_REQUEST_CONTEXT 14
#define CDTTD_JSON_CONTEXT 15
#define CDTTD_VIEW_CONTEXT 16

#define START_CONTEXT CDTINDEX_LOG_CONTEXT
#define END_CONTEXT CDTTD_VIEW_CONTEXT

static DDLogLevel CDTLoggingLevels[] = {[0 ... END_CONTEXT - START_CONTEXT] = DDLogLevelOff};

#define CDTLogError(context, frmt, ...)                                                    \
    LOG_MAYBE(NO, CDTLoggingLevels[context - START_CONTEXT], DDLogFlagError, context, nil, \
              __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define CDTLogWarn(context, frmt, ...)                                                        \
    LOG_MAYBE(YES, CDTLoggingLevels[context - START_CONTEXT], DDLogFlagWarning, context, nil, \
              __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define CDTLogInfo(context, frmt, ...)                                                     \
    LOG_MAYBE(YES, CDTLoggingLevels[context - START_CONTEXT], DDLogFlagInfo, context, nil, \
              __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define CDTLogDebug(context, frmt, ...)                                                     \
    LOG_MAYBE(YES, CDTLoggingLevels[context - START_CONTEXT], DDLogFlagDebug, context, nil, \
              __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define CDTLogVerbose(context, frmt, ...)                                                     \
    LOG_MAYBE(YES, CDTLoggingLevels[context - START_CONTEXT], DDLogFlagVerbose, context, nil, \
              __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define CDTChangeLogLevel(context, logLevel) CDTLoggingLevels[context - START_CONTEXT] = logLevel

#endif
