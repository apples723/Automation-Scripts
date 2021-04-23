#Name: generate_ec2_netbox_import_csv.py
#Author: gsiders
#Purpose: generates a csv of all EC2 instances with IP and DNS hostname that can be used to bulk import IPs into netbox
import boto3
import csv
import socket
#region to lookup 
region = "us-west-1"
#EC2 filter
filter=[{'Name': 'tag:Environment','Values' : ['prod']}]
session = boto3.Session(profile_name='sub', region_name=region)

ec2 = session.client('ec2')

result = []
response = ec2.describe_instances(Filters=filter).get('Reservations')

for item in response:
    for each in item['Instances']:
        ip = each['PrivateIpAddress'] + "/24"
        hostname = socket.gethostbyaddr(each['PrivateIpAddress']) 
        result.append({
            'tenant': '2U US',
            'address': ip,
            'status': 'Active',
            'dns_name': hostname[0]

        })
header = ['tenant', 'address', 'status', 'dns_name']
with open('ec2-details.csv', 'w') as file:
    writer = csv.DictWriter(file, fieldnames=header)
    writer.writeheader()
    writer.writerows(result)
