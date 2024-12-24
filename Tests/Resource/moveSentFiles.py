import os
import shutil
import sys
from datetime import datetime

def move_file(source_folder, destination_folder, file_name):
    try:
        if not os.path.exists(source_folder):
            print("Source folder path does not exist")
            return
        
        if not os.path.exists(destination_folder):
            os.makedirs(destination_folder) 
        
        source_file_path = os.path.join(source_folder, file_name)
        destination_file_path = os.path.join(destination_folder, file_name)
        
        if not os.path.isfile(source_file_path):
            print(f"File '{file_name}' does not exist in source folder")
            return
        
        try:
            shutil.move(source_file_path, destination_file_path)
            
            if not os.path.exists(source_file_path) and os.path.exists(destination_file_path):
                print(f"File moved successfully, '{file_name}'")
            else:
                print(f"Failed to move file '{file_name}'")
        
        except Exception as e:
            print(f"Error occurred while moving file '{file_name}': {str(e)}")
    
    except Exception as e:
        print(f"Error: {str(e)}")


if __name__ == "__main__":
    now = datetime.now()
    current_month = now.strftime("%B")
    current_year = now.year
    source_folder = os.path.join(sys.argv[1], str(current_year), current_month)
    # source_folder = sys.argv[1]
    destination_folder = os.path.join(sys.argv[2], str(current_year), current_month)
    if not os.path.exists(destination_folder):
        os.makedirs(destination_folder)
    # destination_folder = sys.argv[2]
    file_name = sys.argv[3]
    if len(sys.argv) == 4:
        move_file(source_folder, destination_folder, file_name)
        print("Script Processed Successfully")
    else:
        print("Usage: python moveSentFiles.py <source_folder> <destination_folder> <file_name>")
