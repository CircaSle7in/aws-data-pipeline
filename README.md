# README

## Synopsis
This is a datapipeline that:
-  Takes a file from your local machine
-  Uploads the file to an AWS S3 bucket
-  Runs a python script in AWS Lambda to transform your file into a json object
-  Puts your transformed file into a AWS DynamoDB table.

## How to use
### Complete these steps in order:
1. Open up your bash console.
2. Navigate to the directory where you have the unzipped aws-data-pipeline.
```
cd c:\...\aws-data-pipeline
```
3. Navigate to the `Scripts` folder.
```
cd Scripts
```
4. Run the `run.sh` script and wait for completion.
```
sh run.sh
```
5. Run the `uploadfile.sh` script and wait for completion.
```
sh uploadfile.sh
```
6. Open up your web browser and go to your DynamoDB page.  You should see two entries in a table called `Parents`.



## File descriptions:
### In the `Scripts` folder there are three scripts:
- `run.sh`:  
    - This file is what creates the data pipeline.  It will:  
        - Create an S3 bucket
        - Create a role and give it the correct permissions
        - Create a Lambda function from the zipped file `lambda_function.zip`
        - Add permissions and triggers necessary for S3 and Lambda to interact
        - Copy a test file into the bucket to demonstrate the pipeline.  To view the results just open up your AWS Console, open DynamoDB and you should see the table `Parents` with an entry for `testfile.txt`.
- `uploadfile.sh`:
    - This file will allow you to upload your file into the S3 bucket.  It will:  
        - Ask you for the filename.  Please include the file extension type.
        - Ask you for the file path.  Again, please include the file extension in the path.
        - Copy your file into the S3 bucket which then triggers the pipeline.  To view the results just open up your AWS Console, open DynamoDB and you should see the table `Parents` with an entry for your file name.
- `cleanup.sh`:
    - This file will teardown our services that we have created.