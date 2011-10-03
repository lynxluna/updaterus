#!/bin/bash

#  BumpVersion.sh
#  Updaterus
#
#  Created by Muhammad Noor on 9/15/11.
#  Copyright 2011 lynxluna@gmail.com. All rights reserved.

LUBuildPList="${SOURCE_ROOT}/Updaterus for iPad/Updaterus for iPad-Info.plist"
LUBuildNumber=$(/usr/libexec/PlistBuddy -c "Print LUBuildNumber" "$LUBuildPList")
LUBuildNumber=$(($LUBuildNumber + 1))
/usr/libexec/PlistBuddy -c "Set :LUBuildNumber $LUBuildNumber" "$LUBuildPList"
LUBuildDate=$(date +"%Y-%m-%d %H:%M:%S")
/usr/libexec/PlistBuddy -c "Set :LUBuildDate $LUBuildDate" "$LUBuildPList"
LUVersionShort=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$LUBuildPList")
LUBuildNumtrail=$(/usr/bin/printf "%03d" $LUBuildNumber) 
LUVersionLong="$LUVersionShort.$LUBuildNumtrail"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $LUVersionLong" "$LUBuildPList"