# Create a bucket
ECHO "Creating the new bucket..."
aws s3api create-bucket --bucket circa-test-bucket-two --region us-west-2 \
 --create-bucket-configuration LocationConstraint=us-west-2
 
# Create the s3 lambda role
ECHO
ECHO "Creating the new role..."
IAM_ROLE_ARN_LAMBDA=`aws iam create-role --role-name "lambda_s3" \
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
	}'`
ACCOUNT_ID=139422327322
    
# add S3 policy to the created role
ECHO
ECHO "Attaching s3 policy to the new role..."
aws iam attach-role-policy \
  --role-name "lambda_s3" \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess

# Create the lambda function
ECHO
ECHO "Creating the lambda function..."
FUNCTION_NAME="lambda_s3_transformer"
aws lambda create-function --function-name $FUNCTION_NAME  \
     --runtime "python3.7" --role "arn:aws:iam::$ACCOUNT_ID:role/lambda_s3" \
     --handler "lambda_function.lambda_handler" --timeout 3 \
     --memory-size 128 --zip-file "fileb://lambda_function.zip" \
     --region us-west-2

# Add S3 permission to lambda function
ECHO
ECHO "Adding S3 permission to new lambda function..."
aws lambda add-permission --function-name $FUNCTION_NAME \
    --statement-id "s3-put-event-us-west-2" --action "lambda:InvokeFunction"\
    --principal "s3.amazonaws.com" --source-arn "arn:aws:s3:::circa-test-bucket-two" \
    --region us-west-2
    
# Copying new file into the bucket
ECHO
ECHO "Copying the test file into the bucket..."
aws s3 cp d:/circasle7in/projects/divvy/testfile.txt s3://circa-test-bucket-two/testfile.txt