import numpy as np
import sys
import matplotlib.pyplot as plt
import pandas as pd

from utils.main import sx


plt.rcParams['font.sans-serif'] = ['SimHei']  # 使用黑体
plt.rcParams['axes.unicode_minus'] = False    # 正确显示负号

np.set_printoptions(threshold=np.inf, linewidth=200)
pd.set_option('display.max_rows', None)

aa = np.zeros((40, 200, 43))
aperture = np.zeros((20, 200, 21))
percular = np.zeros(aperture.shape)
radius = np.zeros((20, 200))
radiusAll = np.zeros((5, 20, 200))


cracksType = 'ellipse_data_aligned'
dataPath = f'D:\\OneDrive\\Project\\InnovationLib\\Data\\{cracksType}'

for subModel in range(1, 6):
    for table in range(1, 41):
        filePath = f'{dataPath}\\20-cracks-distance-1-{subModel}-AR1\\20-cracks-distance-{table}~40-1-AR1.txt'
        aa[table-1, :, :] = np.loadtxt(filePath, encoding='utf-8', skiprows=5)

    point_n = (aa.shape[2] - 1) // 2
    pointy_start = aa.shape[2] - (aa.shape[2] - 1) // 2

    for i in range(0, 20):
        aperture[i, :, :] = aa[2*i, :, pointy_start:] - aa[2*i+1, :, pointy_start:]

    # 将aperture数组中所有小于1e-7的值设置为0
    aperture[aperture < 1e-7] = 0

    for i in range(0, 20):
        for j in range(0, 200):
            for k in range(0, 21):
                if aperture[i, j, k] <= 1e-7:
                    percular[i, j, k] = 1   

            for k in range(0, point_n-1):
                if percular[i, j, k] * percular[i, j, k+1] == 1:
                    cc = aa[2*i, 0, k+2] - aa[2*i, 0, k+1]
                    radiusAll[subModel-1, i, j] = radiusAll[subModel-1, i, j] + cc                 # 这里radius存储裂隙已闭合的长度

            radiusAll[subModel-1, i, j] = 0.036 - radiusAll[subModel-1, i, j]                      # 这里radius存储裂隙张开部分的长度
            # if radiusAll[subModel-1, i, j] < 1.8e-3:                                # 当裂隙长度小于原长二十分之一时判断为闭合
            #     radiusAll[subModel-1, i, j] = 0


# 绘制直方图
def draw_histogram(radiusAll):
    for subModel in range(1, 6):
        # 创建直方图 - 10个压力条件下完全闭合裂隙数量分布
        fig1, axes = plt.subplots(10, 1, figsize=(12, 20), sharex=True, sharey=True)  # 创建10行1列的子图，共享x轴和y轴

        # 创建等距的区间，从0到0.036
        bins = np.linspace(0, 0.036, 11)  # 11个点，形成10个区间
        bin_width = bins[1] - bins[0]  # 计算区间宽度
        print('区间宽度是:', bin_width)

        p = np.arange(0, 199, 20)[:10]
        print('压力条件是:', p+1)

        # 绘制前10个压力条件下的直方图
        for i in range(10):
            radius_current_pressure = radiusAll[subModel-1, :, p[i]]  # 使用当前subModel的数据
            axes[i].bar((bins[:-1] + bins[1:]) / 2,  # 使用中点作为柱子的x位置
                        np.histogram(radius_current_pressure, bins=bins)[0],
                        width=bin_width * 0.8,
                        label=f'压力 {p[i]+1}')
            axes[i].set_title(f'压力 {p[i]+1} 的 Radius 分布')

        # 设置共享的x轴标签
        plt.xlabel('Radius值 (m)')
        plt.ylabel('裂隙数量')
        plt.xticks(bins)  # 使用bins作为x轴刻度
        
        # 为每个subModel保存单独的图
        plt.savefig(f'radius_distribution_subModel_{subModel}.png')
        plt.close()  # 关闭当前图形，准备创建下一个


# 绘制裂隙长度随压力变化的趋势图
def draw_radius_trend(radiusAll):
    # 创建2行3列的子图布局
    fig2, axes2 = plt.subplots(3, 2, figsize=(25, 10), sharex=True, sharey=True)
    
    # 调整子图之间的间距
    plt.subplots_adjust(wspace=0.3, hspace=0.3)
    
    for subModel in range(1, 6):
        # 计算当前子图的行列位置
        row = (subModel - 1) // 2
        col = (subModel - 1) % 2
        
        axes2[row, col].plot(sx, np.mean(radiusAll[subModel-1, :, :], axis=0))
        axes2[row, col].set_title(f'{cracksType}-1-{subModel}的应力-radius曲线', pad=10)
        axes2[row, col].set_xlabel('压力')
        axes2[row, col].set_ylabel('裂隙长度')
        
        # 添加网格线使图表更易读
        axes2[row, col].grid(True, linestyle='--', alpha=0.7)
    
    # 删除多余的子图
    fig2.delaxes(axes2[2, 1])
    
    # 调整整体布局
    plt.tight_layout()
    plt.savefig(f'radius_trend.png', dpi=300, bbox_inches='tight')
    plt.close()

if __name__ == '__main__':
    # draw_histogram(radiusAll)  # 使用radiusAll而不是radius
    # draw_radius_trend(radiusAll)
    plt.plot(sx, np.mean(radiusAll[0, :, :], axis=0))
    plt.show()



# # 处理每个模型
# for ak in range(6):
#     C_stress = intermediate_C[:, :, :, ak]  # C_eff的维度是(200,5,6,6,6)
#     for am in range(200):
#         C = C_stress[am, :, :]
#         V_dry, CC = modulus_dry_stress(c_1, sita, C, density, a1, a2, a3, p, B, c_density)
#         V_dp[am, ak] = V_dry[0, 0]  # am表示压力，ak表示AR1,AR2,AR1+AR2
#         V_ds[am, ak] = V_dry[1, 7]  # 注意Python索引从0开始，所以这里是7而不是8
    
#     ax1_1.plot(sx, V_dp[:, ak])
#     # ax1_2.plot(sx, V_ds[:, ak])





# for xd in range(1, 6):
#     for table in range(1, 41):
#         filePath = f'{dataPath}\\Data\\data\\20-cracks-distance-1-{xd}-AR1\\20-cracks-distance-{table}~40-{xd}-AR1.txt'
#         aa[table-1, :, :] = np.loadtxt(filePath, encoding='utf-8', skiprows=5)  

#     point_n = (aa.shape[2] - 1) // 2
#     pointy_start = aa.shape[2] - (aa.shape[2] - 1) // 2

#     for i in range(0, 20):
#         aperture[i, :, :] = aa[2*i, :, pointy_start:] - aa[2*i+1, :, pointy_start:]

#     # 将aperture数组中所有小于1e-7的值设置为0
#     aperture[aperture < 1e-7] = 0

#     for i in range(0, 20):
#         for j in range(0, 200):
#             for k in range(0, 21):
#                 if aperture[i, j, k] <= 1e-7:
#                     percular[i, j, k] = 1   

#             for k in range(0, point_n-1):
#                 if percular[i, j, k] * percular[i, j, k+1] == 1:
#                     cc = aa[2*i, 0, k+2] - aa[2*i, 0, k+1]
#                     radius1[xd-1, i, j] = radius1[xd-1, i, j] + cc                 # 这里radius存储裂隙已闭合的长度

#             radius1[xd-1, i, j] = 0.036 - radius1[xd-1, i, j]                       # 这里radius存储裂隙张开部分的长度
#             if radius1[xd-1, i, j] < 3.6e-3:                                       # 这里设置一个阈值，小于判定为已闭合    
#                 radius1[xd-1, i, j] = 0

# radius = np.mean(radius1, axis=0)
