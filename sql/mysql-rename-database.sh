#!/bin/bash

RED="\e[91m\e[1m"
GREEN="\e[32m\e[1m"
BLUE="\e[94m\e[1m"
YELLOW="\e[93m\e[1m"
COLOR_DEFAULT="\e[39m"

function usage() {
  echo -e "${BLUE}Usage: script.sh [options]\n"
  echo "Options:"
  echo "  -s  String: Search database"
  echo "  -r  String: Replace search database"
}

function validate_arguments() {
  if [[ 2 > ${1} ]]; then
    echo -e "\n${RED}== Missing arguments ==\n"
    usage
    exit 1
  fi
}

function database_exists() {
  local dbname="${1}"
  local query="SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = '${dbname}';"
  local result=$(echo "${query}" | ${conn} | grep ${dbname})

  echo ${result}
}

validate_arguments $#

while getopts s:r: option
do
  case "${option}" in
    s) search=${OPTARG};;
    r) replace=${OPTARG};;
  esac
done

if [[ -z "${search}" || -z ${replace} ]]; then
  validate_arguments 0
fi

echo -e "${BLUE}
+-----------------------+
|  s: ${search}
|  r: ${replace}
+-----------------------+
"

credendials=" -uroot -p"

if [ -f "${HOME}/.my.cnf" ]; then
  credendials=""
fi

conn="mysql${credendials}"

if [ -z $(database_exists ${search}) ]; then
  echo -e "${RED}This ( ${search} ) database to search not exists.${COLOR_DEFAULT}"
  exit 1
fi

if [ $(database_exists ${replace}) ]; then
  echo -e "${RED}This ( ${replace} ) database to replace already exists.${COLOR_DEFAULT}"
  exit 1
fi

$conn -e "CREATE DATABASE ${replace};"
echo -e "${GREEN}=== Created database ( ${replace} ) ===${COLOR_DEFAULT}"

tables=$($conn -N -e "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE table_schema='${search}';")

for table in $tables; do
  $conn -e "RENAME TABLE ${search}.${table} to ${replace}.${table}"
  echo "Table (${table}) replaced with success."
done

$conn -e "DROP DATABASE ${search};"

echo -e "${GREEN}=== Deleted database ( ${search} ) ==="
