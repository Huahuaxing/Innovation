import os
import numpy as np

basePath = "./05_Data/SoftCrack/ellipse_data/distance/20-cracks-distance-1-1-AR1"

fileIndexList = [i for i in range(1, 40, 2)]

data = np.zeros((20,200,43))
for index, i in enumerate(fileIndexList, 0):
    fileName = f"20-cracks-distance-{i}~40-1-AR1.txt"
    fullPath = os.path.join(basePath, fileName)
    data[index] = np.loadtxt(fullPath, skiprows=5, encoding="utf-8")

for x, y in zip(data[:, 0, 11], data[:, 0, 33]):
    print(f"{np.floor(x*1000)/1000}, {np.floor(y*1000)/1000}")