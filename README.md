# locksmith
AWS key rotation script for multiple AWS accounts

**NOTE: MAKE SURE YOU HAVE WORKING AWS CONSOLE ACCESS AS A BACKUP TO THIS SCRIPT**



This script will run through each of your profiles in your .aws/credentials file one at a time, query your keys to find any key which has a CreatedDate older than today. It will then create a new access key/secret key, test it, then delete the old key pair. You will receive an error if you already have 2 keys in an account, however the script will keep running to completion, you will then need to go back and manually check each account which failed. 

The script takes a backup copy of your current credentials file named oldcredentials.backup inside your .aws directoy. It then builds a new credentials file in the /tmp directoryas it cycles through the accounts and then overwrites your current credentials file inside .aws/ once it has finished. Any accounts which errored may not appear in the new credentials file so you will need to add them manually once you have checked them in the AWS console as to why they failed (usually because there are 2 keys already present, or your current keys are not valid).

## Usage:
`./locksmith <aws username>`

## To Come...
Rollback - Currently there is no rollback for this script, which is why the script continues to completion upon error. Otherwise you would end up with an even more inconsistent credentials file than you would have if some of the accounts errored along the way. Soon there will be extra checks which will alleviate this and allow for rollback in the case of an error creating a new key.

However... the script will test your current key first before it tries to create a new one in each account. If it fails, then it will skip that account and tell you which account you need to manually check your keys in. 
