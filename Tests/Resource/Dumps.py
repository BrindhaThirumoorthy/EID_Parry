import json
import sys

sys.argv = ["Sales Document: 40025325 | Sold To Party: 'CHOLA PEOPLE AND MARKETING'","Sales Document: 40026200 | Sold To Party: 'PARRY AGRO INDUSTRIES LTD'","Sales Document: 40026201 | Sold To Party: 'PARRY AGRO INDUSTRIES LTD'"]
print("Arguments received:", sys.argv)

# Extract the raw input string from the arguments
raw_input = sys.argv[1]

input_items = raw_input.strip("[]").split(",")

list_new = []
for item in input_items:
    # Remove leading/trailing spaces
    item = item.strip()
    # Parse the "Sales Document" value
    if "Sales Document:" in item:
        sales_document = item.split('|')[0].split(':')[1].strip()
        list_new.append(int(sales_document))

print("Extracted Sales Document list:", list_new, type(list_new))

document_body = [{"document": str(i)} for i in list_new]

document_json = json.dumps(document_body, separators=(',', ':'))

print(f"##gbStart##document_json##splitKeyValue##{document_json}##splitKeyValue##object##gbEnd##")
print("Script Processed Successfully")
