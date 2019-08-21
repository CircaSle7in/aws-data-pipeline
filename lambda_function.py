import boto3
import json

s3_client = boto3.client('s3')
db_client = boto3.client('dynamodb')


def lambda_handler(event, context):
    if event:
        file_obj = event['Records'][0]
        
        # Get information from the S3 event
        bucket_name =  file_obj['s3']['bucket']['name']
        file_name = file_obj['s3']['object']['key']
                
        # Read in the S3 file
        s3_file = s3_client.get_object(Bucket=bucket_name, Key=file_name)
        file_content = s3_file['Body'].read().decode('utf-8')

        # Transform the S3 raw data into the required database format
        parent_data = s3_transformer(file_content)

        # Upload the transformed data to DynamoDB table
        upload_to_dynamo(parent_data, 'Parents')


def s3_transformer(s3_file_text):
    # Clean the newlines and spaces
    text = clean_text(s3_file_text).split(',')

    # Collect the parents and children from the file
    parents = []
    children = []
    for entry in text:
        parents.append(entry.split(' ')[-1])
        children.append(entry.split(' ')[0])

    # Get all the unique entries so that we can create parent entries for everything
    unique_entries = list(set(parents + children))

    # Create dictionaries that have name and children attributes
    parent_keys = []
    for key in unique_entries:
        parent_keys.append({
            'name': key, 
            'children': get_children(key, parents, children)
        })

    return parent_keys


def clean_text(text):
    text = text.replace('\n', '')
    text = text.replace(', ', ',')
    return text


def get_children(key, parent_list, children_list):
    # Find all the children for a given parent
    indeces = [i for i, x in enumerate(parent_list) if x == key]
    return [children_list[i] for i in indeces]


def upload_to_dynamo(parent_data, table_name):
    TABLE_NAME = table_name

    # Create a table in DynamoDB that has a name attribute
    response = db_client.create_table(
        TableName=TABLE_NAME,
        KeySchema=[
            {
                'AttributeName': 'file',
                'KeyType': 'HASH'
            },
        ],
        AttributeDefinitions=[
            {
                'AttributeName': 'file',
                'AttributeType': 'S'
            },
        ],
        ProvisionedThroughput={
            'ReadCapacityUnits': 5,
            'WriteCapacityUnits': 5
        },
    )

    # Write out to the table
    response = db_client.put_item(
        TableName=TABLE_NAME,
        Item={
            'file': {
                'S': 'parent_file',
            },
            'json': {
                'S': json.dumps(parent_data),
            }
        }
    )
