#!/bin/bash
INSTANCES="i-08078d4d94877ab52 i-0012454ff39ed924a i-0034c559e0525127a i-0cf62708792d5fdf1 i-09c840bbce1b4917f i-0196790f70bd7eee2"

case $1 in
  stop)
    echo "Stopping cluster..."
    aws ec2 stop-instances --region us-east-1 --instance-ids $INSTANCES --output text
    ;;
  start)
    echo "Starting cluster..."
    aws ec2 start-instances --region us-east-1 --instance-ids $INSTANCES --output text
    echo "Waiting for instances to be running..."
    aws ec2 wait instance-running --region us-east-1 --instance-ids $INSTANCES
    echo "Done! Run: kubectl get nodes"
    ;;
  *)
    echo "Usage: $0 {start|stop}"
    ;;
esac
