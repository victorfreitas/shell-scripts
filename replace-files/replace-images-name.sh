#!/bin/bash

RED="\e[91m\e[1m"
GREEN="\e[32m\e[1m"
BLUE="\e[94m\e[1m"
YELLOW="\e[93m\e[1m"
COLOR_DEFAULT="\e[39m"

function usage() {
  echo -e "\n${BLUE}Usage: script.sh [options]\n"
  echo "Options:"
  echo "  -d  String: absolute path to find images"
  echo "  -s  String: Search image name"
  echo "  -r  String: Replace search image name"
  echo "  -h  Empty value for show help"
  exit 0
}

function without_dir() {
  local value=$(echo "${1}" | sed -e "s|${dir}||g")
  echo ${value}
}

while getopts s:r:d:h option
do
  case "${option}" in
    s) search=${OPTARG};;
    r) replace=${OPTARG};;
    d) dir=${OPTARG};;
    h) usage;;
  esac
done

if [[ -z "${search}" ]] || [[ -z "${replace}" ]]; then
  echo -e "${RED}Arguments ${COLOR_DEFAULT}-s (search)${RED} and ${COLOR_DEFAULT}-r (replace)${RED} is required"
  exit 1
fi

if [ ! -d "${dir}" ]; then
  echo -e "${RED}Directory (${dir}) not exists."
  exit 1
fi

find "${dir}" -type f -iregex ".*${search}.*\.\(png\|jpe?g\|gif\|ico\|svg\)" |
while read file; do
  fileDir=$(dirname "${file}")
  fileBase=$(basename "${file}")
  newFilename=$(echo ${fileBase} | sed -e "s|${search}|${replace}|i");
  mv "${file}" "${fileDir}/${newFilename}"
  echo -e "${GREEN}$(without_dir ${file}) ${YELLOW}moved to${GREEN} $(without_dir ${fileDir})/${newFilename}"
done
