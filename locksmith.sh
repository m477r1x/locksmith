#!/bin/bash
set -ex
Echo "Please enter AWS Username:"
read user

for account in $(cat ~/.aws/credentials  | grep '\[.*\]' | grep -v '^\[180374546468' |  tr -d '[]'); do 
OldKeyID=$(aws iam list-access-keys --user $user --query "AccessKeyMetadata[?CreateDate<='$(date +%F),AccessKeyId']" --output text --profile $account | awk '{print $1}');
aws iam create-access-key --user-name $user --output text --profile $account | awk '{print "['$account']\n""aws_access_key_id = "$2"\n""aws_secret_access_key = "$4"\n"}' >> /tmp/credentials
if [ $? -eq 0 ]; then
	echo "Successfully created new key in "$account
else
	tput bold
	echo "Failed to create new key in "$account" probably too many keys present"
	tput sgr0
fi;
echo "Waiting to ensure new key is active..."
sleep 5
echo "Testing new access key for account "$account;
aws sts get-caller-identity;
if [ $? -eq 0 ]; then
	echo "Successful"
else 
	tput bold
	echo "Error check account " $account
	tput sgr0
fi;
echo "Deleting old access key from "$account;
aws iam delete-access-key --access-key-id $OldKeyID --user-name $user --profile $account;
echo "Key rotated for account: "$account; done
tput bold
Echo "Updating credentials file"
tput sgr0
mv /tmp/credentials ~/.aws/credentials
if [ $? -eq 0 ]; then
	echo "Credentials file updated"
else
	tput bold
	echo "Failed to update new credentials file, check /tmp/credentials"
	tput sgr0
fi;