import numpy as np
from matplotlib import pyplot as plt

BasePath = r"D:\Projects\02_Innovation\06_Results\03_Single_Crack_Area"
FilePath1 = "upper_surface.txt"
FilePath2 = "lower_surface.txt"

import os
FullPath1 = os.path.join(BasePath, FilePath1)
FullPath2 = os.path.join(BasePath, FilePath2)

data_upper = np.loadtxt(FullPath1, comments="%", encoding="utf-8")
data_lower = np.loadtxt(FullPath2, comments="%", encoding="utf-8")
Stress= data_upper[:, 0]

ylim_max = data_upper[0,51:].max()
ylim_min = data_lower[0,51:].min()

index = np.arange(1, 52, 1)[::5] - 1

plt.figure(figsize=(10,12))
plt.plot(data_upper[1, 1:51], data_upper[1, 51:], 'r')
plt.plot(data_lower[1, 1:51], data_lower[1, 51:], 'r')
# plt.ylim(ylim_min, ylim_max)
plt.show()


# fig = plt.figure(figsize=(8, 10))
# # gs = fig.add_gridspec(nrows=len(Stress[::5]), ncols=1, width_ratios=[1, 1])
# axes = fig.subplots(len(index), 1, sharex = True, sharey = True)
# for i in range(len(index)):
#     axes[i].plot(data_upper[index[i],1:51], data_upper[index[i],51:], 'r')
#     axes[i].plot(data_lower[index[i],1:51], data_lower[index[i],51:], 'r')
#     axes[i].set_ylim(0.12295, 0.12305)
#     if i < len(index)-1:
#         axes[i].set_xticklabels([])
# plt.tight_layout()
# plt.show()