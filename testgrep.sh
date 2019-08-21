ACCOUNT_ID=`aws sts get-caller-identity | jq -r '.Account'`
ECHO $ACCOUNT_ID