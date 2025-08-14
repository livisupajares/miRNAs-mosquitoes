# ~~~~ TEST ID MAPPING FORMAT ~~~~~~
# It seems like UniProt changed their ID mapping API response format
# Deprecated old format
# "to": { "id": "UPI0007D30AB1" }
# New format current:
# "to": "UPI0007D30AB1"

import requests

url = "https://rest.uniprot.org/idmapping/results/7ac97af16g"
headers = {"Accept": "application/json"}

res = requests.get(url, headers=headers)
data = res.json()

to_value = data["results"][0]["to"]
print("Type of 'to':", type(to_value))
print("Value:", to_value)

# ✅ Correct way:
if isinstance(to_value, str):
    uniparc_id = to_value
elif isinstance(to_value, dict):
    uniparc_id = to_value["id"]

print("UniParc ID:", uniparc_id)
