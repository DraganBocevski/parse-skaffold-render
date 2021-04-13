#!/bin/bash

# This script expects one parameter - the file path of a `skaffold render` output file
# This file contains all the skaffold rendered manifests into a single file
# This script processes this file to split all the k8s manifests into separate files
# The script expects the input file to start with a "# Source" path to a file to start to write to 
# Lines containing "---" are ignored

# When skaffold render is used, skaffold keeps the source path information for every file
# For example : # Source: kfraud-istio/templates/ingressgw-istiooperator.yaml
# This path is extracted and used to separate the manifests into directories

ManifestsDir="Manifests"

# The output manifests are generated in the $ManifestsDir dir
rm -rf "$ManifestsDir"
mkdir "$ManifestsDir"


outputPath=""

# IFS is set to empty to include the leading empty spaces in the read -r command
# This is needed to keep the yaml structure correct
# OIFS is a temp var used to hold the previous value of IFS so we can set it back later
OIFS=$IFS
IFS=

# We are processing the input file line by line and we output the lines to output files
# When the delimiter line is found in the form of # Source: ..., we start output to a new file
# The path of the new file is extracted from the delimiter line 
while read -r line; do

    shouldSwitch=`echo $line | cut -c1-10`
    if [[ "$shouldSwitch" == "# Source: " ]]
    then
	    # We have hit the delimiter line. We are extracting the new path
	    echo ""
	    #echo ""

	    # Take the new output path (everything after # Source: )
	    outputPath=`echo $line | cut -c11-`

	    # Get the directory from path
	    outputDir=`dirname $outputPath`
	    
	    # Remove the /templates suffix from dir. This is specific, might have to be skipped in some cases
	    # outputDir=${outputDir%/*}

	    # Create the new dir as $ManifestsDir/dir (if doesn't already exist - to avoid errors when multiple templates in the same dir)
	    [ ! -d "$ManifestsDir/$outputDir" ] && mkdir -p "$ManifestsDir/$outputDir"

	    # Get the new output file
	    outputFile=`basename $outputPath`
            printf "%s" "$ManifestsDir/$outputDir/$outputFile"

    else
	    # Skip line if contains "---"
	    # Otherwise, write line to output file
	    if [[ "$line" != "---" ]]
	    then
	        printf "."
		echo $line >> "$ManifestsDir/$outputDir/$outputFile"
	    fi
    fi
    # echo "$line"
done < "${1:-/dev/stdin}"

echo ""

# Return the previous value of IFS
IFS=$OIFS
