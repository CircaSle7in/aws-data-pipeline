REGION='us-west-2'
ACCOUNT_ID=`aws sts get-caller-identity | jq -r '.Account'`
BUCKET_NAME="$ACCOUNT_ID-upload"
ROLE_NAME='LambdaS3'
FUNCTION_NAME='LambdaS3Transformer'
HANDLER_NAME='lambda_function.lambda_handler'

ECHO 'Cleaning up...'
ECHO
ECHO 'Deleting bucket...'
aws s3 rm s3://$BUCKET_NAME --recursive
aws s3api delete-bucket --bucket $BUCKET_NAME

ECHO
ECHO 'Deleting function...'
aws lambda delete-function --function-name $FUNCTION_NAME

ECHO
ECHO 'Bucket and function have been deleted'