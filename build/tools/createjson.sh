#!/bin/bash
#
# Copyright (C) 2019-2023 crDroid Android Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#$1=TARGET_DEVICE, $2=PRODUCT_OUT, $3=FILE_NAME
existingOTAjson=./OTA/$1.json
output=$2/$1.json

#cleanup old file
if [ -f $output ]; then
	rm $output
fi

echo "Generating JSON file data for OTA support..."

if [ -f $existingOTAjson ]; then
	#get data from already existing device json
	#there might be a better way to parse json yet here we try without adding more dependencies like jq
	buildprop=$2/system/build.prop
	linenr=`grep -n "ro.build.date.utc" $buildprop | cut -d':' -f1`
	datetime=`sed -n $linenr'p' < $buildprop | cut -d'=' -f2`
	filename=$3
	id=`sha256sum "$2/$3" | cut -d' ' -f1`
	romtype=UNOFFICIAL
	size=`stat -c "%s" "$2/$3"`
	version=`echo "$3" | cut -d'-' -f2`
	v_max=`echo "$version" | cut -d'.' -f1 | cut -d'v' -f2`
	v_min=`echo "$version" | cut -d'.' -f2`
	version=`echo $v_max.$v_min`

	echo '{
	"response": [
      {
		"datetime": '$datetime',
		"filename": "'$filename'",
		"id": "'$id'",
		"romtype": "'$romtype'",
		"size": '$size',
		"url": "https://sourceforge.net/projects/los-garnet/files/'$1'/'$3'/download",
		"version": "'$version'"
	  }
	]
}' >> $output
else
	buildprop=$2/system/build.prop
	linenr=`grep -n "ro.build.date.utc" $buildprop | cut -d':' -f1`
	datetime=`sed -n $linenr'p' < $buildprop | cut -d'=' -f2`
	filename=$3
	id=`sha256sum "$2/$3" | cut -d' ' -f1`
	romtype=UNOFFICIAL
	size=`stat -c "%s" "$2/$3"`
	version=`echo "$3" | cut -d'-' -f2`
	v_max=`echo "$version" | cut -d'.' -f1 | cut -d'v' -f2`
	v_min=`echo "$version" | cut -d'.' -f2`
	version=`echo $v_max.$v_min`

    echo '{
	"response": [
      {
		"datetime": '$datetime',
		"filename": "'$filename'",
		"id": "'$id'",
		"romtype": "'$romtype'",
		"size": '$size',
		"url": "https://sourceforge.net/projects/los-garnet/files/'$1'/'$3'/download",
		"version": "'$version'"
	  }
	]
}' >> $output

	echo 'There is no official support, this is just an unofficial one that supports OTA to make it easier when updating.'
fi

echo ""
