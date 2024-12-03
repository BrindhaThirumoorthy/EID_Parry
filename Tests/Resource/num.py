import pandas as pd

# def number_to_string(file_path, column_letter):
#     # Load the Excel file
#     df = pd.read_excel(file_path)
    
#     # Convert column letter (like "H") to a zero-based index
#     column_index = ord(column_letter.upper()) - ord('A')
    
#     # Get the column name from the DataFrame
#     column_name = df.columns[column_index]
    
#     # Apply the transformation to the specified column
#     if column_name in df.columns:
#         df[column_name] = df[column_name].apply(lambda value: f'"{value}"' if pd.notnull(value) else value)
        
#         # Save back to the file
#         df.to_excel(file_path, index=False)
#     else:
#         print(f"Column {column_letter} not found in the Excel file.")

# # File path and column reference
# file_path = "C:\\TEMP\\rental.xlsx"
# column = "H"
# number_to_string(file_path, column)
# import  json
# import pandas as pd
# import json

# def excel_to_json_new(excel_file, json_file):
#     df = pd.read_excel(excel_file, engine='openpyxl')
#     for column in df.select_dtypes(['datetime']):
#         df[column] = df[column].astype(str)
#     for column in df.columns:
#         if df[column].dtype == 'object': 
#             df[column] = df[column].str.strip('"') 
    
#     data = df.to_dict(orient='records')
#     with open(json_file, 'w', encoding='utf-8') as f:
#         json.dump(data, f, ensure_ascii=False, indent=4)
#     with open(json_file, 'r', encoding='utf-8') as f:
#         json_data = json.load(f)
#     return json_data

# excel_file = "C:\\TEMP\\rental.xlsx"
# json_file = "C:\\TEMP\\final.json"
# excel_to_json_new(excel_file,json_file)

import json
 
def extract_dates(json_string):
    date_list =[]
    start_date = json_string["startDate"]
    date_list.append(start_date)
    end_date = json_string["endDate"]
    date_list.append(end_date)
    print(date_list,type(date_list),len(date_list))
    return date_list
 
# Example usage
json_string = {"startDate":"01.11.2024","endDate":"30.11.2024"}
start_date, end_date = extract_dates(json_string)
print("Start Date:", start_date)
print("End Date:", end_date)
 
 