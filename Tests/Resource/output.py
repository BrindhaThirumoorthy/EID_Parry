import sys

output = sys.argv[1]
print(output)

if len(sys.argv) == 2:
    print(f"##gbStart##document_number##splitKeyValue##{output}##gbEnd##")
else:
    print("Please supply all the arguments.")
    sys.exit(1)