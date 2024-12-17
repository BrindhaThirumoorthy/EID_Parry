import pandas as pd
import json
import os
from datetime import time

def convert_excel_to_json(excel_file, json_file):
    df = pd.read_excel(excel_file, engine='openpyxl')
    df = df.where(pd.notnull(df), "empty")
    for column in df.select_dtypes(['datetime']):
        df[column] = df[column].astype(str)
    for column in df.columns:
        if df[column].dtype == 'object': 
            df[column] = df[column].str.strip('"') 
    data = df.to_dict(orient='records')
    with open(json_file, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=4)
    with open(json_file, 'r', encoding='utf-8') as f:
        json_data = json.load(f)
    return json_data
    # for column in df.columns:
    #     if pd.api.types.is_datetime64_any_dtype(df[column]):
    #         df[column] = df[column].astype(str)
    #     elif pd.api.types.is_timedelta64_dtype(df[column]):
    #         df[column] = df[column].astype(str)
    #     elif pd.api.types.is_object_dtype(df[column]):
    #         df[column] = df[column].apply(
    #             lambda x: x.strftime('%H:%M:%S') if isinstance(x, time) else x
    #         )
    # data = df.to_dict(orient='records')
    
    # # Write the dictionary to a JSON file
    # with open(json_file, 'w', encoding='utf-8') as f:
    #     json.dump(data, f, ensure_ascii=False, indent=4)

def read_json(json_file):
    # Open and read the JSON file
    with open(json_file, 'r', encoding='utf-8') as f:
        data = json.load(f)
    value = json.dumps(data, indent=4)
    return value

def delete_files(files):
    for file in files:
        try:
            os.remove(file)
            print(f"Deleted file: {file}")
        except Exception as e:
            print(f"Error deleting file {file}: {e}")

def convert_json_to_string(input):
    value = json.dumps(data, indent=4)
    # print(value)
    return value

# Example usage
# excel_file = r'C:\\Output\\Rental_output.xlsx'  # Replace with your Excel file path
json_file = r'C:\Output\Rental_Status.json'  # Replace with your desired JSON file path
# convert_json_to_string(data)

# convert_excel_to_json(excel_file, json_file)
data = read_json(json_file)
data1 = convert_json_to_string(data)
print(f"##gbStart##copilot_key##splitKeyValue##{data1}##splitKeyValue##object##gbEnd##")

# Delete the files
# delete_files([excel_file, json_file])
