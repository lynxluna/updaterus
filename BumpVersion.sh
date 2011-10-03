#!/bin/bash

#  BumpVersion.sh
#  MindTalk
#
#  Created by Muhammad Noor on 9/15/11.
#  Copyright 2011 lynxluna@gmail.com. All rights reserved.

MTBuildPList="${SOURCE_ROOT}/MindTalk/MindTalk-Info.plist"
MTBuildNumber=$(/usr/libexec/PlistBuddy -c "Print MTBuildNumber" $MTBuildPList)
MTBuildNumber=$(($MTBuildNumber + 1))
/usr/libexec/PlistBuddy -c "Set :MTBuildNumber $MTBuildNumber" $MTBuildPList
MTBuildDate=$(date +"%Y-%m-%d %H:%M:%S")
/usr/libexec/PlistBuddy -c "Set :MTBuildDate $MTBuildDate" $MTBuildPList
MTVersionShort=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" $MTBuildPList)
MTVersionLong="$MTVersionShort.$MTBuildNumber"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $MTVersionLong" $MTBuildPList