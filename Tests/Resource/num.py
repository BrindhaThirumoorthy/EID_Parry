import pandas as pd

def number_to_string(file_path, column_letter):
    # Load the Excel file
    df = pd.read_excel(file_path)
    
    # Convert column letter (like "H") to a zero-based index
    column_index = ord(column_letter.upper()) - ord('A')
    
    # Get the column name from the DataFrame
    column_name = df.columns[column_index]
    
    # Apply the transformation to the specified column
    if column_name in df.columns:
        df[column_name] = df[column_name].apply(lambda value: f'"{value}"' if pd.notnull(value) else value)
        
        # Save back to the file
        df.to_excel(file_path, index=False)
    else:
        print(f"Column {column_letter} not found in the Excel file.")

# File path and column reference
file_path = "C:\\TEMP\\rental.xlsx"
column = "H"
number_to_string(file_path, column)
