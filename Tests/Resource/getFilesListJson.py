import os
import json
import sys
from datetime import datetime

def check_files_in_folder(folder_path):
    try:
        if not os.path.exists(folder_path):
            return json.dumps({"error": "Folder path does not exist"})
        
        files_present = [file for file in os.listdir(folder_path) if os.path.isfile(os.path.join(folder_path, file))]
        
        if files_present:
            formatted_files = [{"file": file} for file in files_present]
            return json.dumps(formatted_files)
        else:
            return "No files present at the moment"
    
    except Exception as e:
        return json.dumps({"error": str(e)})


if __name__ == "__main__":
    if len(sys.argv) == 2:
        now = datetime.now()
        current_month = now.strftime("%B")
        current_year = now.year
        # folder_path = sys.argv[1]
        folder_path = os.path.join(sys.argv[1], str(current_year), current_month)
        result = check_files_in_folder(folder_path)
        print(f"##gbStart##invoiceFilesList##splitKeyValue##{result}##splitKeyValue##object##gbEnd##")
        print("Script Processed Successfully")
    else:
        print("Usage: python getFilesListJson.py <folder_path>")
