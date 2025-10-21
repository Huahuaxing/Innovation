import numpy as np
import matplotlib.pyplot as plt

# 设置中文字体
plt.rcParams['font.sans-serif'] = ['SimHei']  # 用来正常显示中文标签
plt.rcParams['axes.unicode_minus'] = False     # 用来正常显示负号

n = 1

data = np.loadtxt(f'./Data/Finally/data_final_{n}/data_final_{n}_1.txt', encoding='utf-8', comments='%') # (200, 41)

deformation = data[1: , 30] - data[:-1 , 30]     # 形变长度，第二行到最后一行-第一行到倒数第二行
strain = deformation / data[0, 30]                 # 应变，size:199，第二行到最后一行

stress = data[1:, 0] - data[:-1, 0]       # 应力=300kpa，第二行到最后一行-第一行到倒数第二行

static_modulus = stress / strain                         # 应力应变比（静态模量），size:199

static_modulus_slope = (abs(static_modulus[-3]) - abs(static_modulus[-1])) / (data[-4, 0] - data[-2, 0])
cx = data[:-1, 0] - data[0, 0]
static_modulus_add = static_modulus + static_modulus_slope * cx             # size:199


# 相对应变
deformation = data[1:, 30] - data[1, 30]
strain = deformation / data[0, 30]               # size = 199

fig, axs = plt.subplots(2, 2, figsize=(10, 8))  # axs 是一个包含4个坐标轴的数组

# 访问各个坐标轴
ax1, ax2, ax3, ax4 = axs.flatten()  # 将2D数组展平为1D数组，方便解包

# 第一个图：静态模量
ax1.plot(data[:199, 0], abs(static_modulus_add[:199]), '-ok', label = '修正值')  # 修正
ax1.plot(data[:199, 0], abs(static_modulus[:199]), '-r', label = '未修正值')       # 未修正
ax1.set_title('静态模量图')
ax1.set_xlabel('轴向压力(Pa)', fontsize = 12)
ax1.set_ylabel('静态模量(GPa)', fontsize = 12)
ax1.legend()
ax1.grid(True)

# 第二个图：压力-应变图
ax2.plot(data[1:, 0], abs(strain), '-ok', label = '相对应变')
ax2.set_title('压力-应变图')
ax2.set_xlabel('轴向压力(Pa)', fontsize = 12)
ax2.set_ylabel('相对应变', fontsize = 12)
ax2.legend()
ax2.grid(True)

# 第三个图：绝对应变-压力图
ax3.plot(abs(strain), data[1:, 0], '-ok', label = '绝对应变')
ax3.set_title('绝对应变图')
ax3.set_xlabel('绝对应变', fontsize = 12)
ax3.set_ylabel('轴向压力(Pa)', fontsize = 12)
ax3.legend()
ax3.grid(True)

# 第四个图：相对应变-压力图
ax4.plot(abs(strain), data[1:, 0], '-ok', label = '相对应变')
ax4.set_title('相对应变图')
ax4.set_xlabel('相对应变', fontsize = 12)
ax4.set_ylabel('轴向压力(Pa)', fontsize = 12)
ax4.legend()
ax4.grid(True)
# ax1.set_aspect('equal')  # 设置x轴和y轴的比例相同

plt.tight_layout()

plt.show()