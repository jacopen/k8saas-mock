#!/bin/bash

CMDNAME=`basename $0`
TEMPLATE_DIR=./templates
BASE_DIR=$PWD

_usage(){
    echo "Usage: $CMDNAME [-c CLUSTER_ID]" 1>&2
    exit 1
}

while getopts c:h OPT
do
  case $OPT in
    "c" ) ENABLE_c="true"; CLUSTER_ID="$OPTARG" ;;
    "h" ) _usage ;;
    *) _usage ;;
  esac
done

[ "${ENABLE_c}" != "true" ] && _usage


echo "Creating TF file for $CLUSTER_ID"
mkdir -p clusters/$CLUSTER_ID
cp $TEMPLATE_DIR/workspace/ws.tf workspaces/$CLUSTER_ID.tf
cp $TEMPLATE_DIR/aks/aks.tf clusters/$CLUSTER_ID/aks.tf 
sed -i "s/CLUSTER_ID/$CLUSTER_ID/g" workspaces/$CLUSTER_ID.tf
sed -i "s/CLUSTER_ID/$CLUSTER_ID/g" clusters/$CLUSTER_ID/*

echo "Commit files to the repository"
git add workspaces/$CLUSTER_ID.tf clusters/$CLUSTER_ID
git commit -m "Add $CLUSTER_ID"
git push origin main

echo "Waiting 90sec"
sleep 90

echo "Waiting 90sec"
WS_ID=`curl \
  --header "Authorization: Bearer $TFE_TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  https://app.terraform.io/api/v2/organizations/kusama/workspaces \
  | jq ".data[] | select (.attributes.name==\"$CLUSTER_ID\")" | jq -r .id`

cat request.json | sed "s/WS_ID/$WS_ID/" | curl \
  --header "Authorization: Bearer $TFE_TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  --request POST \
  --data @- \
  https://app.terraform.io/api/v2/runs
