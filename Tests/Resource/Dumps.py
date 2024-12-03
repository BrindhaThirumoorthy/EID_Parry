import  json
import sys
print(sys.argv)
# list_value = "40025323, 40025326,40025328,40025330"
list_value = sys.argv[1]

list_new = [int(i.strip()) for i in list_value.split(",")]
print(list_new, type(list_new))

# list_value = list(list_value)

document_body = [{"document":f"{i}"} for i in list_new]

document_json = json.dumps(document_body, separators=(',',':'))

print(f"##gbStart##document_json##splitKeyValue##{document_json}##splitKeyValue##object##gbEnd##")
# print(f"##gbStart##document_json##splitKeyValue##{document_json}##gbEnd##")
print("Script Processed Successfully")