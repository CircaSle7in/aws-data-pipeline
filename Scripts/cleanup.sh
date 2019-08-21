BUCKET_NAME='circa-test-bucket-two'
REGION='us-west-2'
ACCOUNT_ID=`aws sts get-caller-identity | jq -r '.Account'`
ROLE_NAME='LambdaS3'
FUNCTION_NAME='lambda_s3_transformer'
HANDLER_NAME='lambda_function.lambda_handler'

ECHO 'Cleaning up...'
ECHO
ECHO 'Deleting bucket...'
aws s3api delete-bucket --bucket $BUCKET_NAME

ECHO
ECHO 'Deleting role...'
aws iam delete-role --role-name $ROLE_NAME

ECHO
ECHO 'Deleting function...'
aws lambda delete-function --function-name $FUNCTION_NAME

ECHO
ECHO 'Completed teardown!'