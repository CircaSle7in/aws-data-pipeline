#Set variables that will be used later
BUCKET_NAME='circa-test-bucket-two'
REGION='us-west-2'
ACCOUNT_ID=`aws sts get-caller-identity | jq -r '.Account'`
FUNCTION_NAME="lambda_s3_transformer"

# Create a bucket
ECHO "Creating the new bucket..."
aws s3api create-bucket --bucket $BUCKET_NAME --region $REGION \
 --create-bucket-configuration LocationConstraint=$REGION
 
# Create the s3 lambda role
ECHO
ECHO "Creating the new role..."
aws iam create-role --role-name "lambda_s3" \
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
    
# add S3 policy to the created role
ECHO
ECHO "Attaching s3 policy to the new role..."
aws iam attach-role-policy \
  --role-name "lambda_s3" \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess

# Create the lambda function
ECHO
ECHO "Creating the lambda function..."
aws lambda create-function --function-name $FUNCTION_NAME  \
     --runtime "python3.7" --role "arn:aws:iam::$ACCOUNT_ID:role/lambda_s3" \
     --handler "lambda_function.lambda_handler" --timeout 3 \
     --memory-size 128 --zip-file "fileb://lambda_function.zip" \
     --region $REGION 
     
FUNCTION_ARN=`aws lambda get-function-configuration --function-name $FUNCTION_NAME \
    | jq -r '.FunctionArn'`
    
ECHO $FUNCTION_ARN
     
# Adding Lambda trigger for S3 object create
ECHO
ECHO "Adding lambda trigger for S3 object create"
aws s3api put-bucket-notification-configuration --bucket $BUCKET_NAME \
    --notification-configuration '{
        "LambdaFunctionConfigurations": [
        {
          "Id": "s3-event-triggers-lambda",
          "LambdaFunctionArn": "$FUNCTION_ARN",
          "Events": ["s3:ObjectCreated:Put"]
          }
      ]
    }'

# Add S3 permission to lambda function
ECHO
ECHO "Adding S3 permission to new lambda function..."
aws lambda add-permission --function-name $FUNCTION_NAME \
    --statement-id "s3-put-event-$REGION" --action "lambda:InvokeFunction"\
    --principal "s3.amazonaws.com" --source-arn "arn:aws:s3:::$BUCKET_NAME" \
    --region $REGION
    
# 
    
# Copying new file into the bucket
ECHO
ECHO "Copying the test file into the bucket..."
aws s3 cp d:/circasle7in/projects/divvy/aws-data-pipeline/testfile.txt s3://$BUCKET_NAME/testfile.txt