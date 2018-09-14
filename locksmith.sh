#!/bin/bash
Echo "Please enter AWS Username:"
read user

for account in $(cat ~/.aws/credentials | grep '\[.*\]' |  tr -d '[]'); do 
OldKeyID=$(aws iam list-access-keys --user $user --query "AccessKeyMetadata[?CreateDate<='$(date +%F),AccessKeyId']" --output text --profile $account | awk '{print $1}');
aws sts get-caller-identity --profile $account --output text | awk '{print "Current Access Key "$3" for account: '$account' is valid, beginning rotation"}'
if [ $? -eq 0 ]; then
	aws iam create-access-key --user-name $user --output text --profile $account | awk '{print "['$account']\n""aws_access_key_id = "$2"\n""aws_secret_access_key = "$4"\n"}' >> /tmp/credentials
		if [ $? -eq 0 ]; then
			echo "Successfully created new key in "$account
		else
			tput bold
			echo "Failed to create new key in "$account" probably too many keys present, or must be logged in using MFA"
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
	echo "Updating credentials file"
	tput sgr0
	mv /tmp/credentials ~/.aws/credentials
		if [ $? -eq 0 ]; then
		echo "Credentials file updated"
	else
		tput bold
		echo "Failed to update new credentials file, check /tmp/credentials"
		tput sgr0
	fi;
else 
	echo "Your current key for "$account" does not work, this needs fixing manually before you continue"
fi;
done
