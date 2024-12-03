import  json
import sys

# list_value = ["40025323","40025326","40025328","40025330"]
list_value = sys.argv[1]
list_val = [int(i) for i in list_value.split(",")]
print(type(list_val))
document_json = {"documents": []}

for i in list_value:
    document_json["documents"].append(i)

print(f"##gbStart##document_json##splitKeyValue##{document_json}##splitKeyValue##object##gbEnd##")
print("Script Processed Successfully")