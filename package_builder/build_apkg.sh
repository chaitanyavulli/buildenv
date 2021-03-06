#!/usr/bin/env bash

exitError()
{
    echo "ERROR $1: $3" 1>&2
    echo "ERROR     LOCATION=$0" 1>&2
    echo "ERROR     LINE=$2" 1>&2
    exit $1
}


TEMP=$@
eval set -- "$TEMP --"
while true; do
    case "$1" in
        --package|-p) package=$2; shift 2;;
        --dir|-d) package_basedir=$2; shift 2;;
        -- ) shift; break ;;
        * ) fwd_args="$fwd_args $1"; shift ;;
    esac
done

if [[ -z ${package} ]]; then
    exitError 2220 ${LINENO} "package option has to be specified"
fi

if [[ -z ${package_basedir} ]]; then
    exitError 2221 ${LINENO} "package basedir has to be specified"
fi

BASEPATH_SCRIPT=$(dirname "${0}")
envloc="${BASEPATH_SCRIPT}/.."

# setup module environment and default queue
if [ ! -f ${envloc}/machineEnvironment.sh ] ; then
    exitError 2222 ${LINENO} "could not find ${envloc}/env/machineEnvironment.sh"
fi
source ${envloc}/machineEnvironment.sh
# load machine dependent functions
if [ ! -f ${envloc}/env.${host}.sh ] ; then
    exitError 2223 ${LINENO} "could not find ${envloc}/env/env.${host}.sh"
fi
source ${envloc}/env.${host}.sh

# load module tools
if [ ! -f ${envloc}/moduleTools.sh ] ; then
    exitError 1203 ${LINENO} "could not find ${envloc}/env/moduleTools.sh"
fi
source ${envloc}/moduleTools.sh

fwd_args="${fwd_args} -d ${package_basedir} -i ${installdir}"

package_buildscript="${BASEPATH_SCRIPT}/build_${package}.sh"
if [ -f $package_buildscript ] ; then
    echo "Building specific package: ${package_buildscript} $fwd_args"
    . ${package_buildscript} $fwd_args
else
    exitError 2221 ${LINENO} "Package ${package} not known"
fi

