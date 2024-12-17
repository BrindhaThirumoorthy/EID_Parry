import pandas as pd
import json
import os
from datetime import time

def convert_excel_to_json(excel_file, json_file):
    # Read the Excel file
    df = pd.read_excel(excel_file, engine='openpyxl')
    df = df.where(pd.notnull(df), "empty")

    # Convert datetime and time objects to strings
    for column in df.columns:
        if pd.api.types.is_datetime64_any_dtype(df[column]):
            df[column] = df[column].astype(str)
        elif pd.api.types.is_timedelta64_dtype(df[column]):
            df[column] = df[column].astype(str)
        elif pd.api.types.is_object_dtype(df[column]):
            df[column] = df[column].apply(
                lambda x: x.strftime('%H:%M:%S') if isinstance(x, time) else x
            )
    
    # Convert the DataFrame to a dictionary
    data = df.to_dict(orient='records')
    
    # Write the dictionary to a JSON file
    with open(json_file, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=4)

def read_json(json_file):
    # Open and read the JSON file
    with open(json_file, 'r', encoding='utf-8') as f:
        data = json.load(f)
    return data

def delete_files(files):
    for file in files:
        try:
            os.remove(file)
            print(f"Deleted file: {file}")
        except Exception as e:
            print(f"Error deleting file {file}: {e}")

# Example usage
excel_file = r'C:\TEMP\rental.xlsx'  # Replace with your Excel file path
json_file = r'C:\TEMP\rental.json'  # Replace with your desired JSON file path

convert_excel_to_json(excel_file, json_file)
data = read_json(json_file)
print(f"##gbStart##copilot_key##splitKeyValue##{data}##splitKeyValue##object##gbEnd##")

# Delete the files
# delete_files([excel_file, json_file])
