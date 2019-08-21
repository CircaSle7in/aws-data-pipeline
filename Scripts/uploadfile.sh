ACCOUNT_ID=`aws sts get-caller-identity | jq -r '.Account'`
BUCKET_NAME="$ACCOUNT_ID-upload"
REGION='us-west-2'

ECHO
read -p 'What is the filename that you would like to upload? ' FILE_NAME

ECHO 
read -p 'What is the file path to the file you would like to upload? ' FILE_PATH

ECHO
ECHO 'Copying file into s3 bucket...'
aws s3 cp $FILE_PATH s3://$BUCKET_NAME/$FILE_NAME