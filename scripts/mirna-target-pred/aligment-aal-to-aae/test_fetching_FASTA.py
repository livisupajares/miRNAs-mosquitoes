# ~~~~~ FETCH UNIPROT PROTEIN SEQUENCES ~~~~~ #
# Import dependencies
import os
import time

import requests
from bs4 import BeautifulSoup

# Test data for minimun working example: One file.
acc = "A0A023ETG1"  # Example from bantam-3p
