#!/bin/bash
Echo "Please enter AWS Username:"
read user


cp ~/.aws/credentials ~/.aws/oldcredentials.backup
for account in $(cat ~/.aws/credentials | grep '\[.*\]' |  tr -d '[]'); do 
	aws iam get-user --user-name $user --profile $account
	if [ $? -eq 0 ]; then
		echo Valid User, Continuing...

aws iam list-access-keys --user $user --query "AccessKeyMetadata[?CreateDate<='$(date +%F),AccessKeyId']" --output text --profile $account | awk '{print $1}'
aws sts get-caller-identity --profile $account --output text | awk '{print "Current Access Key "'$OldKeyID'" for account: '$account' is valid, beginning rotation"}'
newcreds=$(aws iam create-access-key --user-name $user --output text --profile $account | awk '{print$2" "$4}')
 		newaccesskey=$(echo $newcreds | awk '{print$1}')
 		newsecretkey=$(echo $newcreds | awk '{print$2}')
 		printf [$account]"\n""aws_access_key_id = "$newaccesskey"\n""aws_secret_access_key = "$newsecretkey"\n""\n" >> /tmp/credentials
 
 		echo "Waiting to ensure new key is active..."
 		sleep 10
 		echo "Testing new access key for account "$account	
 		AWS_ACCESS_KEY_ID=${newaccesskey} AWS_SECRET_ACCESS_KEY=${newsecretkey} aws sts get-caller-identity
			if [ $? -eq 0 ]; then
 				echo "Successful"
 				echo "Deleting old access key from "$account
				aws iam delete-access-key --access-key-id $OldKeyID --user-name $user --profile $account;
 				echo "Key rotated for account: "$account
 			else 
 				tput bold
 				echo "Error check account "$account
 				tput sgr0
 			fi;
	else
		tput bold
		echo No such user in this account!
		tput sgr0
	fi;

	done
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