#Set variables that will be used later
BUCKET_NAME='circa-test-bucket-two'
REGION='us-west-2'
ACCOUNT_ID=`aws sts get-caller-identity | jq -r '.Account'`
ROLE_NAME='LambdaS3'
FUNCTION_NAME='lambda_s3_transformer'
HANDLER_NAME='lambda_function.lambda_handler'
TEST_FILE_PATH='d:/circasle7in/projects/divvy/aws-data-pipeline/files/testfile.txt'
TEST_FILE_NAME='testfile.txt'

cd ..

# Create a bucket
ECHO "Creating the new bucket..."
aws s3api create-bucket --bucket $BUCKET_NAME --region $REGION \
 --create-bucket-configuration LocationConstraint=$REGION
 
# Create the s3 lambda role
ECHO
ECHO "Creating the new role..."
aws iam create-role --role-name $ROLE_NAME \
	--assume-role-policy-document '{
		"Version": "2012-10-17",
	   	"Statement": [
	    {
	    	"Effect": "Allow",
	       	"Principal": {
	        	"Service": "lambda.amazonaws.com"
	    	},
	    	"Action": "sts:AssumeRole"
	    }
		]
	}'
    
ECHO
ECHO "Attaching admin access policy to the new role..."
aws iam attach-role-policy \
  --role-name $ROLE_NAME \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess

# Create the lambda function
ECHO
ECHO "Creating the lambda function..."
aws lambda create-function --function-name $FUNCTION_NAME  \
     --runtime "python3.7" --role "arn:aws:iam::$ACCOUNT_ID:role/$ROLE_NAME" \
     --handler $HANDLER_NAME --timeout 3 \
     --memory-size 128 --zip-file "fileb://lambda_function.zip" \
     --region $REGION 
     
# Add S3 permission to lambda function
ECHO
ECHO "Adding S3 permission to new lambda function..."
aws lambda add-permission --function-name $FUNCTION_NAME \
    --statement-id "s3-put-event-$REGION" --action "lambda:InvokeFunction"\
    --principal "s3.amazonaws.com" --source-arn "arn:aws:s3:::$BUCKET_NAME" \
    --region $REGION
     
FUNCTION_ARN="arn:aws:lambda:$REGION:$ACCOUNT_ID:function:$FUNCTION_NAME"
VAR1='{
        "LambdaFunctionConfigurations": [
        {
          "Id": "s3-event-triggers-lambda",
          "LambdaFunctionArn": "'
VAR2='",
          "Events": ["s3:ObjectCreated:Put"]
          }
      ]
    }'
     
# Adding Lambda trigger for S3 object create
ECHO
ECHO "Adding lambda trigger for S3 object create"
aws s3api put-bucket-notification-configuration --bucket $BUCKET_NAME \
    --notification-configuration "$VAR1$FUNCTION_ARN$VAR2"
    
# Copying new file into the bucket
ECHO
ECHO "Copying the test file into the bucket..."
aws s3 cp $TEST_FILE_PATH s3://$BUCKET_NAME/$TEST_FILE_NAME