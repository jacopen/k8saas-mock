#!/bin/bash

CMDNAME=`basename $0`
TEMPLATE_DIR=./templates

while getopts c: OPT
do
  case $OPT in
    "c" ) CLUSTER_ID="$OPTARG" ;;
      * ) echo "Usage: $CMDNAME [-c CLUSTER_ID]" 1>&2
          exit 1 ;;
  esac
done


mkdir -p clusters/$CLUSTER_ID
cp $TEMPLATE_DIR/workspace/ws.tf workspaces/$CLUSTER_ID.tf
cp $TEMPLATE_DIR/aks/aks.tf clusters/$CLUSTER_ID/aks.tf 
sed -i "s/CLUSTER_ID/$CLUSTER_ID/g" workspaces/$CLUSTER_ID.tf
sed -i "s/CLUSTER_ID/$CLUSTER_ID/g" clusters/$CLUSTER_ID/*