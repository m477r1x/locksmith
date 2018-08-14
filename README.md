# locksmith
AWS key rotation script for multiple AWS accounts

**NOTE: MAKE SURE YOU HAVE WORKING AWS CONSOLE ACCESS AS A BACKUP TO THIS SCRIPT**



This script will run through each of your profiles in your .aws/credentials file one at a time, query your keys to find any key which has a CreatedDate older than today. It will then create a new access key/secret key, test it, then delete the old key pair. You will receive an error if you already have 2 keys in an account, however the script will keep running to completion, you will then need to go back and manually check each account which failed. 

The script builds a new credentials file in the /tmp directory and then overwrites your current credentials file inside .aws/ once it has finished. Any accounts which errored may not appear in the new credentials file so you will need to add them manually once you have checked them in the AWS console as to why they failed (usually because there are 2 keys already present, or your current keys are not valid).
