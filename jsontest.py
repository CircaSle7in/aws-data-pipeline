import boto3
import json

s3_client = boto3.client('s3')
db_client = boto3.client('dynamodb')

def clean_text(text):
    text = text.replace('\n', '')
    text = text.replace(', ', ',')
    return text

def get_children(key, parent_list, children_list):
    indeces = [i for i, x in enumerate(parent_list) if x == key]
    return [children_list[i] for i in indeces]


FILE_PATH = 'd:/circasle7in/projects/divvy/aws-data-pipeline/testfile.txt'

with open(FILE_PATH) as f:
    text = f.read()

text = clean_text(text).split(',')

parents = []
children = []
for entry in text:
    parents.append(entry.split(' ')[-1])
    children.append(entry.split(' ')[0])

unique_entries = list(set(parents + children))

parent_keys = []
for key in unique_entries:
    parent_keys.append({
        'name': key, 
        'children': get_children(key, parents, children)
    })

def upload_to_dynamo(json_file):
    TABLE_NAME = 'test_table'
    try:
        response = db_client.create_table(
            TableName=TABLE_NAME,
            KeySchema=[
                {
                    'AttributeName': 'name',
                    'KeyType': 'HASH'
                },
                {
                    'AttributeName': 'children',
                    'KeyType': 'RANGE'
                }
            ],
            AttributeDefinitions=[
                {
                    'AttributeName': 'name',
                    'AttributeType': 'S'
                },
                {
                    'AttributeName': 'children',
                    'AttributeType': 'SS'
                }
            ],
            ProvisionedThroughput={
                'ReadCapacityUnits': 5,
                'WriteCapacityUnits': 5
            },
        )
    except:
        print('The table has already been created')

    response = db_client.put_item(
        TableName=TABLE_NAME,
        Item={
            'name': parent_keys[0]['name'],
            'children': parent_keys[0]['children']
        }
    )

upload_to_dynamo(parent_keys)

TABLE_NAME = 'test_table'
response = db_client.create_table(
    TableName=TABLE_NAME,
    KeySchema=[
        {
            'AttributeName': 'name',
            'KeyType': 'HASH'
        },
    ],
    AttributeDefinitions=[
        {
            'AttributeName': 'name',
            'AttributeType': 'S'
        },
    ],
    ProvisionedThroughput={
        'ReadCapacityUnits': 5,
        'WriteCapacityUnits': 5
    },
)

for parent in parent_keys:
    print(parent['children'], not parent['children'])
    if not parent['children']:
        response = db_client.put_item(
            TableName=TABLE_NAME,
            Item={
                'name': {
                    'S': parent['name'],
                },
                'children': {
                    'SS': parent['children'],
                }
            }
        )
    else:
        response = db_client.put_item(
            TableName=TABLE_NAME,
            Item={
                'name': {
                    'S': parent['name'],
                },
                'children': {
                    'SS': parent['children'],
                }
            }
        )

