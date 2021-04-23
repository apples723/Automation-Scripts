#Name: add_ec2_tags.py
#Author: gsiders
#Purpose: Bulk add tags to EC2 instances
import boto3

ec2 = boto3.client('ec2','us-east-1')
#finds windows ec2 instances, can change filter to other use cases if needed
response = ec2.describe_instances(Filters=[{'Name' : 'platform','Values' : ['windows']}])
instances = response['Reservations']
#tags to add
tags_to_add = [
  {
    'Key':'ManagePatches',
    'Value':'True'
  },
  {
    'Key':'Patch Group',
    'Value':'Production'
  },
  {
    'Key':'Scan-Patches',
    'Value':'True'
  },
  { 
    'Key':'Install-Patches',
    'Value':'False'
  }
]
instance_ids = []
for i in instances:
  instance_ids.append(i['Instances'][0]['InstanceId'])
ec2.create_tags(Resources=instance_ids,Tags=tags_to_add)
