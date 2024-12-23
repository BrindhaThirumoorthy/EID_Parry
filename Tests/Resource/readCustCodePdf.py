# import fitz  # PyMuPDF
# import re
# import os
# import sys

# def extract_text_from_first_page(pdf_path):
#     with fitz.open(pdf_path) as pdf:
#         first_page_text = pdf[0].get_text("blocks")
#     return first_page_text

# def parse_key_value_pairs(text_blocks):
#     parsed_data = {}
#     recipient_details = None
    
#     recipient_pattern = re.compile(r'Details of Recipient (?P<content>[^)]+)')
    
#     combined_text = " ".join(block[4] for block in text_blocks)
    
#     key_value_pattern = re.compile(r'(?P<key>[\w\s]+)\s*:\s*(?P<value>[^\n]+)')
#     matches = key_value_pattern.findall(combined_text)
#     for key, value in matches:
#         parsed_data[key.strip()] = value.strip()
    
#     match = recipient_pattern.search(combined_text)
#     if match:
#         recipient_details = match.group("content").strip()
    
#     return parsed_data, recipient_details


# if __name__ == "__main__":

#     folder_path = sys.argv[1]
#     file_name = sys.argv[2]
#     if len(sys.argv) == 3:
#         pdf_path = os.path.join(folder_path, file_name)

#         text_blocks = extract_text_from_first_page(pdf_path)
#         print(text_blocks)
#         parsed_content, recipient_info = parse_key_value_pairs(text_blocks)
#         print(parsed_content)
#         print(recipient_info)
#         recipient_info = recipient_info.split('-')[-1].strip()
#         print(f"##gbStart##bp_number##splitKeyValue##{recipient_info}##splitKeyValue##object##gbEnd##")
#         print("Script Processed Successfully")
    
#     else:
#         print("Usage: python readCustCodePdf.py <folder_path> <file_name>")
#         sys.exit(1)

import fitz  # PyMuPDF
import re
import os
import sys

def extract_text_from_first_page(pdf_path):
    with fitz.open(pdf_path) as pdf:
        first_page_text = pdf[0].get_text("text")
    return first_page_text.splitlines()

def parse_key_value_pairs(lines):
    parsed_data = {}
    recipient_details = None
    
    recipient_pattern = re.compile(r'Details\s*of\s*Recipient\s*(?P<content>[^)]+)') # String Pattern Regex format.
    key_value_pattern = re.compile(r'(?P<key>[\w\s]+)\s*:\s*(?P<value>[^\n]+)')
    
    for line in lines:
        # Search for key-value pairs
        key_value_match = key_value_pattern.match(line)
        if key_value_match:
            parsed_data[key_value_match.group("key").strip()] = key_value_match.group("value").strip()
        
        # Check for 'Details of Recipient' in the line
        words = line.split()
        if len(words) >= 3:
            for i in range(len(words) - 2):
                if words[i].lower() == "details" and words[i + 1].lower() == "of" and words[i + 2].lower() == "recipient":
                    recipient_match = recipient_pattern.search(line)
                    if recipient_match:
                        recipient_details = recipient_match.group("content").strip()
    
    return parsed_data, recipient_details

if __name__ == "__main__":

    folder_path = sys.argv[1]
    file_name = sys.argv[2]
    
    if len(sys.argv) == 3:
        pdf_path = os.path.join(folder_path, file_name)

        lines = extract_text_from_first_page(pdf_path)
        parsed_content, recipient_info = parse_key_value_pairs(lines)
        
        for line in lines:
            print(line)
        
        print(parsed_content)
        if recipient_info:
            recipient_info = recipient_info.split('-')[-1].strip()
            print(f"##gbStart##bp_number##splitKeyValue##{recipient_info}##splitKeyValue##object##gbEnd##")
        else:
            print(f"Recipient info could not be parsed. Please process the file {sys.argv[2]} manually.")
        
        print("Script Processed Successfully")
    
    else:
        print("Usage: python readCustCodePdf.py <folder_path> <file_name>")
        sys.exit(1)
