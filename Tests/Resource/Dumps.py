import json
import sys

# sys.argv = ["script_name", '["Sales Document: 40026233 | Sold-To-Party: 800597", "Sales Document: 40026234 | Sold-To-Party: 800597"]']
print(sys.argv)

# Extracting the input JSON array from the arguments
input_array = json.loads(sys.argv[1])

# Extracting Sales Document values
list_new = [int(item.split('|')[0].split(':')[1].strip()) for item in input_array]
print(list_new, type(list_new))

# Creating the document body structure
document_body = [{"document": f"{i}"} for i in list_new]

# Converting to JSON
document_json = json.dumps(document_body, separators=(',', ':'))

# Printing the output in the specified format
print(f"##gbStart##document_json##splitKeyValue##{document_json}##splitKeyValue##object##gbEnd##")
print("Script Processed Successfully")