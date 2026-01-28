# 通过cosmol导出的distance数据，反推出丢失的ellipse model的裂隙坐标

import os
import numpy as np

groupNum = 6
subModelNum = 5
crackNum = 20
stressNum = 200

inputBasePath = os.path.join(".", "05_Data", "SoftCrack", "ellipse_data", "distance")
fileIndexList = [i for i in range(1, crackNum*2, 2)]
singleModelData = np.zeros((crackNum,stressNum,43))
allModelCrackPosition = np.zeros((groupNum, subModelNum, crackNum, 2))

ARList = ["AR1", "AR2", "AR1+AR2", "AR1+AR2", "AR1+AR2", "AR1+AR2"]
for g in range(groupNum):
    for s in range(subModelNum):
        for index, i in enumerate(fileIndexList, 0):
            modelName = f"20-cracks-distance-{g+1}-{s+1}-{ARList[g]}"
            crackName = f"20-cracks-distance-{i}~40-{s+1}-{ARList[g]}.txt"
            fullPath = os.path.join(inputBasePath, modelName, crackName)
            singleModelData[index] = np.loadtxt(fullPath, skiprows=5, encoding="utf-8")
            allModelCrackPosition[g, s, :, 0] = np.round(singleModelData[:, 0, 11], 3)
            allModelCrackPosition[g, s, :, 1] = np.round(singleModelData[:, 0, 33], 3)

outputBasePath = os.path.join(".", "05_Data", "SoftCrack", "source_model", "ellipse_source")
outputARList = ["20AR1", "20AR2", "16AR1+4AR2", "12AR1+8AR2", "8AR1+12AR2", "4AR1+16AR2"]
for g in range(groupNum):
    groupName = f"第{g+1}组_{outputARList[g]}"
    fullPath = os.path.join(outputBasePath, groupName)
    os.makedirs(fullPath, exist_ok=True)
    for s in range(subModelNum):
        savePath = os.path.join(fullPath, f"position{s+1}.txt")
        np.savetxt(savePath, allModelCrackPosition[g, s, :, :], delimiter=",", encoding="utf-8", fmt="%.3f")


