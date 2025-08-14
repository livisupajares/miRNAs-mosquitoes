# ~~~~ TEST UNIPROT ID MAPPING JOB ~~~~~
# This is a minimal example with one single job (uniprot id).
# This is important to test if by adding headers stops the 404 Client Error
# from fetch-uniprot-pro-seq.py script
import requests

url = "https://rest.uniprot.org/idmapping/results/gJDqMeglZx"
headers = {"Accept": "application/json"}

res = requests.get(url, headers=headers)
print(res.status_code)
print(res.json())
