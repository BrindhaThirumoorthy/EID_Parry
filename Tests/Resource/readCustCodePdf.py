import fitz  # PyMuPDF
import re
import os
import sys

def extract_text_from_first_page(pdf_path):
    with fitz.open(pdf_path) as pdf:
        first_page_text = pdf[0].get_text("blocks")
    return first_page_text

def parse_key_value_pairs(text_blocks):
    parsed_data = {}
    recipient_details = None
    
    recipient_pattern = re.compile(r'Details of Recipient (?P<content>[^)]+)')
    
    combined_text = " ".join(block[4] for block in text_blocks)
    
    key_value_pattern = re.compile(r'(?P<key>[\w\s]+)\s*:\s*(?P<value>[^\n]+)')
    matches = key_value_pattern.findall(combined_text)
    for key, value in matches:
        parsed_data[key.strip()] = value.strip()
    
    match = recipient_pattern.search(combined_text)
    if match:
        recipient_details = match.group("content").strip()
    
    return parsed_data, recipient_details


if __name__ == "__main__":

    folder_path = sys.argv[1]
    file_name = sys.argv[2]
    if len(sys.argv) == 3:
        pdf_path = os.path.join(folder_path, file_name)

        text_blocks = extract_text_from_first_page(pdf_path)
        print(text_blocks)
        parsed_content, recipient_info = parse_key_value_pairs(text_blocks)
        print(parsed_content)
        print(recipient_info)
        recipient_info = recipient_info.split('-')[-1].strip()
        print(f"##gbStart##bp_number##splitKeyValue##{recipient_info}##splitKeyValue##object##gbEnd##")
        print("Script Processed Successfully")
    
    else:
        print("Usage: python readCustCodePdf.py <folder_path> <file_name>")
        sys.exit(1)
