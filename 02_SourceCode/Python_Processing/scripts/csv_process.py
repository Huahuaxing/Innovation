import json
import csv
import numpy as np

# 读取 JSON 文件
with open("properties.json", "r") as f:
    data1 = json.load(f)

P = data1["P"]

# 读取现有的 CSV 文件（使用读取模式 "r"）
data2 = []
with open("./05_ProcessedData/velocity/old/isotropic_matrix/n_20/degree_90/vp_polygonal.csv", "r") as f:  # 使用 vp_ellipse.csv 而不是空的 vp_polygonal.csv
    csv_reader = csv.reader(f)
    for row in csv_reader:
        if row:  # 确保行不为空
            data2.append(float(row[0]))  # 取第一列数据

print(f"P length: {len(P)}")
print(f"data2 length: {len(data2)}")

a = []
min_length = min(len(P), len(data2))
for i in range(min_length):
    a.append(f"({P[i]},{data2[i]})")

with open("./a.txt", "w") as f:
    for item in a:
        f.write(item + "\n")
