import boto3
import json

s3_client = boto3.client('s3')
db_client = boto3.client('dynamodb')


def lambda_handler(event, context):
    if event:
        file_obj = event['Records'][0]
        
        # Get neccesarry info ex) bucket name, file name, region, account # and so on
        bucket_name =  file_obj['s3']['bucket']['name']
        file_name = file_obj['s3']['object']['key']
                
        fileObj = s3.get_object(Bucket=bucket_name, Key=file_name)
        file_content = fileObj['Body'].read().decode('utf-8')

        json_file_content = s3_transformer(file_content)


def s3_transformer(s3_file_text):
    text = clean_text(s3_file_text).split(',')
    parents = []
    children = []
    for entry in text:
        parents.append(entry.split(' ')[-1])
        children.append(entry.split(' ')[0])

    unique_entries = list(set(parents + children))

    parent_keys = []
    for key in unique_entries:
        parent_keys.append(json.dumps(
            {
                'name': key, 
                'children': get_children(key, parents, children)
            })
        )
    return parent_keys


def clean_text(text):
    text = text.replace('\n', '')
    text = text.replace(', ', ',')
    return text


def get_children(key, parent_list, children_list):
    indeces = [i for i, x in enumerate(parent_list) if x == key]
    return [children_list[i] for i in indeces]


def upload_to_dynamo(json_file):
    response = db_client.create_table(
        AttributeDefinitions={
            'AttributeName': 'name',
            'AttributeType': 'S',
        },
        {
            'AttributeName': 'children',
            'AttributeType': 'S',
        }
    )
