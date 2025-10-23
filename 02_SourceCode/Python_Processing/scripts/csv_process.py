import json


with open("properties.json", "r") as f:
    data = json.load(f)

P = data["P"]

with open(r"D:/Projects/02_Innovation/05_ProcessedData/velocity/old/isotropic_matrix/n_20/degree_90/vp_polygonal.csv", "r") as f:

