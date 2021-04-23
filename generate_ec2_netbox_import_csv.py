#Name: generate_ec2_netbox_import_csv.py
#Author: gsiders
#Purpose: generates a csv of all EC2 instances with IP and DNS hostname that can be used to bulk import IPs into netbox
#Note: Boto3 accepts several ways to auth to AWS, this scripts assumes you have a credentials file created and have set the env variable 'AWS_SHARED_CREDENTIALS_FILE' 


import boto3
import csv
import socket
#region to lookup 
region = "us-west-1"
#EC2 filter
filter=[{'Name': 'tag:Environment','Values' : ['prod']}]
session = boto3.Session(profile_name='sub', region_name=region)

ec2 = session.client('ec2')
#results list used for creating csv
result = []
#get all instances matching filter
response = ec2.describe_instances(Filters=filter).get('Reservations')
#cycle through all instnaces and add need data to results list
for item in response:
    for each in item['Instances']:
        #Ip format required by netbox
        ip = each['PrivateIpAddress'] + "/24"
        #rather than pull the hostname tag from AWS lookup the DNS name
        hostname = socket.gethostbyaddr(each['PrivateIpAddress']) 
        result.append({
            'tenant': '2U US',
            'address': ip,
            'status': 'Active',
            'dns_name': hostname[0]

        })
#fields supported by netbox
header = ['tenant', 'address', 'status', 'dns_name']
#create csv
with open('outputs/netbox_import.csv', 'w') as file:
    writer = csv.DictWriter(file, fieldnames=header)
    writer.writeheader()
    writer.writerows(result)
