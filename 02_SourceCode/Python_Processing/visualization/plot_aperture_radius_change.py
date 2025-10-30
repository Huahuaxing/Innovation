'''
加载comsol生成的六组模型数据结果,选择每组第一个模型绘制以下图像：
1、绘制应力-aperture曲线
2、绘制应力-radius曲线
'''

import numpy as np
import sys
import matplotlib.pyplot as plt
import json
import os

class DataProcess:
    def __init__(self, basePath) -> None:
        self.basePath = basePath
        self.table = np.zeros((40, 200, 43))                 # 存储所有数据文件的数组
        self.aperture = np.zeros((20, 200, 21))              # 存储计算出来的开度

        self.radius_random = np.zeros((5, 20, 200))
        self.radius_record = np.zeros((5, 20, 200, 6))
        self.aperture_random = np.zeros((5, 1, 200))
        self.aperture_record = np.zeros((5, 20, 200, 6))

    # 加载1-1到1-5
    def load_group_1(self):
        results = []
        for xd in range(1, 6):                          # 五个模型
            for xs in range(1, 41):                     # 四十个表格
                file_path = f'{self.basePath}\\20-cracks-distance-1-{xd}-20AR1\\20-cracks-distance-{xs}~40-1-AR1.txt'
                self.table[xs-1, :, :] = np.loadtxt(file_path, encoding='utf-8', skiprows=5)     # 1D：裂隙上下界面的点；2D：不同压力；3D：坐标值

            point_n = (self.table.shape[2] - 1) // 2         # 点数量
            pointy_start_index = self.table.shape[2] - (self.table.shape[2] - 1) // 2                 # self.table数组第三维索引从22-42表示y坐标，共21个点

            self.aperture.fill(0)
            for xs in range(0, 20):
                self.aperture[xs, :, :] = self.table[2*xs, :, pointy_start_index:] - self.table[2*xs+1, :, pointy_start_index:]

            percular = np.zeros((self.table.shape[0], self.table.shape[1], point_n))          # (20, 200, 21)，0/1数组，0代表张开，1代表完全闭合
            radius = np.zeros((self.table.shape[0]//2, self.table.shape[1]))                  # (20, 200)

            for xs in range(0, self.aperture.shape[0]):
                for xt in range(0, self.aperture.shape[1]):
                    for xu in range(0, self.aperture.shape[2]):
                        if self.aperture[xs, xt, xu] <= 1e-7:                            # 设置一个阈值，小于判定为已闭合
                            percular[xs, xt, xu] = 1

                    for xu in range(0, point_n-1):
                        if percular[xs, xt, xu] * percular[xs, xt, xu+1] == 1:
                            cc = self.table[2*xs, 0, xu+2] - self.table[2*xs, 0, xu+1]        # 这里加2是因为self.table数组第一列是应力，从第二列开始才是坐标
                            radius[xs, xt] = radius[xs, xt] + cc                    # 这里radius存储裂隙已闭合的长度

                    radius[xs, xt] = 0.036 - radius[xs, xt]                         # 换算成张开的长度
                    # if radius[xs, xt] < 5e-5:
                    #     radius[xs, xt] = 0

            aperture_aver = np.mean(self.aperture, axis=2)       # （20, 200）单个裂隙平均开度
            aperture_a = np.mean(aperture_aver, axis=0)     # （200）20个裂隙平均开度
            
            # 收集每组需要画图的数据
            stress = self.table[0, :, 0]
            results.append({'stress': stress, 'aperture': aperture_a})
            self.aperture_random[xd-1, :, :] = aperture_a                                    # （5, 1, 200），每个模型，每个应力条件下的平均开度
            self.radius_random[xd-1, :, :] = radius                                          # （5, 20, 200），每个模型，每个裂隙，每个应力条件下的长轴长度
            self.radius_record[xd-1, :, :, 0] = radius                                       # （5, 20, 200, 6），存储的是裂隙的长轴半径
            self.aperture_record[xd-1, :, :, 0] = (np.pi * 0.036 / 2) * aperture_aver        # （5, 20, 200, 6），存储的是裂隙的等效面积

            # avera = np.zeros((5, 200))
            # avera_aper = np.zeros((5, 200))

            # for xs in range(0, 5):
            #     for kk in range(0, 200):
            #         avera[xs,kk] = np.mean(radius_random[xs,:,kk])         #  (5, 200)每个模型每个应力条件下，二十个裂隙的平均长轴长度
            #         avera_aper[xs,kk] = sum(aperture_random[xs,:,kk])/20   # （5，200）？

            # var = np.zeros(200)
            # for kk in range(0, 200):
            #     var[kk] = np.std(avera[:,kk])  # 每个应力条件下，五个模型的avera的标准差

            # avera_self.table = np.mean(avera,0)        # (200)，每个应力条件下，五个模型的avera的平均值
            # avera_aperture = (np.pi * 0.036 / 2) * np.mean(avera_aper,0)

            # bb = np.arange(1, 200, 10)          # 以10为步长，取应力数组
            # ssx = np.squeeze(self.table[0,bb,0])        # 应力数组

            # ax2.plot(ssx, avera_self.table[bb], 'c')
            # ax3.plot(ssx, avera_aperture[bb], 'c')

        return results

    # 加载2-1到2-5
    def load_group_2(self):
        results = []
        for xd in range(1, 6):
            for xs in range(1, 41):
                file_path = f'{self.basePath}\\20-cracks-distance-2-{xd}-20AR2\\20-cracks-distance-{xs}~40-{xd}-20AR2.txt'
                self.table[xs-1, :, :] = np.loadtxt(file_path, encoding='utf-8', skiprows=5)
            
            point_n = (self.table.shape[2] - 1) // 2
            pointy_start = self.table.shape[2] - (self.table.shape[2] - 1) // 2
            
            self.aperture.fill(0)
            for xs in range(1, 21):
                self.aperture[xs-1, :, :] = self.table[2*xs-2, :, pointy_start:] - self.table[2*xs-1, :, pointy_start:]
            
            self.aperture[self.aperture <= 1e-7] = 0
            
            percular = np.zeros((self.table.shape[0], self.table.shape[1], point_n))
            radius = np.zeros((self.table.shape[0]//2, self.table.shape[1]))
            
            for xs in range(0, self.aperture.shape[0]):
                for xt in range(0, self.aperture.shape[1]):
                    for xu in range(0, self.aperture.shape[2]):
                        if self.aperture[xs, xt, xu] <= 1e-7:                # 设置一个阈值，小于判定为已闭合
                            percular[xs, xt, xu] = 1

                    for xu in range(0, point_n-1):
                        if percular[xs, xt, xu] * percular[xs, xt, xu+1] == 1:
                            cc = self.table[2*xs, 0, xu+2] - self.table[2*xs, 0, xu+1]      # 这里加2是因为self.table数组第一列是应力，从第二列开始才是坐标
                            radius[xs, xt] = radius[xs, xt] + cc            # 这里radius存储裂隙已闭合的长度

                    radius[xs, xt] = 0.036 - radius[xs, xt]
                    # if radius[xs, xt] < 5e-5:
                    #     radius[xs, xt] = 0
            
            aperture_aver = np.sum(self.aperture, axis=2) / point_n
            aperture_a = np.sum(aperture_aver, axis=0) / 20
            
            self.aperture_random[xd-1, :, :] = aperture_a
            self.radius_random[xd-1, :, :] = radius
            self.radius_record[xd-1, :, :, 5] = radius  # 在Python中索引是5
            self.aperture_record[xd-1, :, :, 5] = (np.pi * 0.036 / 2) * aperture_aver
            stress = self.table[0, :, 0]
            results.append({'stress': stress, 'aperture': aperture_a})
        return results

    # 加载3-1到6-5 部分
    def load_group_3_6(self):
        ARList = ['4AR1+16AR2', '8AR1+12AR2', '12AR1+8AR2', '16AR1+4AR2']
        results = []
        for xe in range(3, 7):
            for xd in range(1, 6):
                for xs in range(1, 41):
                    file_path = f'{self.basePath}\\20-cracks-distance-{xe}-{xd}-{ARList[xe-3]}\\20-cracks-distance-{xs}~40-{xd}-{ARList[xe-3]}.txt'
                    self.table[xs-1, :, :] = np.loadtxt(file_path, encoding='utf-8', skiprows=5)
                
                point_n = (self.table.shape[2] - 1) // 2
                pointy_start = self.table.shape[2] - (self.table.shape[2] - 1) // 2
                
                self.aperture.fill(0)
                for xs in range(1, 21):
                    self.aperture[xs-1, :, :] = self.table[2*xs-2, :, pointy_start:] - self.table[2*xs-1, :, pointy_start:]
                
                self.aperture[self.aperture <= 1e-7] = 0
                
                percular = np.zeros((self.table.shape[0], self.table.shape[1], point_n))
                radius = np.zeros((self.table.shape[0]//2, self.table.shape[1]))
                
                for xs in range(0, self.aperture.shape[0]):
                    for xt in range(0, self.aperture.shape[1]):
                        for xu in range(0, self.aperture.shape[2]):
                            if self.aperture[xs, xt, xu] <= 1e-7:                # 设置一个阈值，小于判定为已闭合
                                percular[xs, xt, xu] = 1

                        for xu in range(0, point_n-1):
                            if percular[xs, xt, xu] * percular[xs, xt, xu+1] == 1:
                                cc = self.table[2*xs, 0, xu+2] - self.table[2*xs, 0, xu+1]      # 这里加2是因为self.table数组第一列是应力，从第二列开始才是坐标
                                radius[xs, xt] = radius[xs, xt] + cc            # 这里radius存储裂隙已闭合的长度

                        radius[xs, xt] = 0.036 - radius[xs, xt]
                        # if radius[xs, xt] < 5e-5:
                        #     radius[xs, xt] = 0
                
                aperture_aver = np.sum(self.aperture, axis=2) / point_n
                aperture_a = np.sum(aperture_aver, axis=0) / 20
                
                # 绘制压力-开度曲线
                self.aperture_random[xd-1, :, :] = aperture_a
                self.radius_random[xd-1, :, :] = radius
                self.radius_record[xd-1, :, :, xe-2] = radius
                self.aperture_record[xd-1, :, :, xe-2] = (np.pi * 0.036 / 2) * aperture_aver
                stress = self.table[0, :, 0]
                results.append({'stress': stress, 'aperture': aperture_a, 'group': xe, 'model': xd})
        return results

sx = np.squeeze(self.table[0, :, 0])

# 设置图形属性
# fig1设置（压力-开度曲线）
# fig1.legend(subModel) # This line was removed as per the edit hint to remove redundant code.
fig1.suptitle('五个子模型压力-开度曲线')
ax1.set_ylabel('Aperture (m)', fontsize=12)
ax1.set_xlabel('Pressure (Pa)', fontsize=12)  # 只在底部子图设置x轴标签
fig1.set_size_inches(25/2.54, 35/2.54)  # 厘米转英寸

# # fig2设置（ssx-avera曲线）
# fig2.legend(model)
# fig2.suptitle('六个不同AR模型的Pressure-Radius曲线')
# ax2.set_ylabel('Radius (m)', fontsize=12)
# ax2.set_xlabel('Pressure (Pa)', fontsize=12)  # 只在底部子图设置x轴标签
# fig2.set_size_inches(25/2.54, 35/2.54)  # 厘米转英寸

# # fig3设置（ssx-avera_aperture曲线）
# fig3.legend(model)
# fig3.suptitle('六个不同AR模型的Pressure-Aperture曲线')
# ax3.set_ylabel('Aperture (m)', fontsize=12)
# ax3.set_xlabel('Pressure (Pa)', fontsize=12)  # 只在底部子图设置x轴标签
# fig3.set_size_inches(25/2.54, 35/2.54)  # 厘米转英寸



if __name__ == "__main__":
    # 设置中文字体支持
    plt.rcParams['font.sans-serif'] = ['SimHei']  # 使用黑体
    plt.rcParams['axes.unicode_minus'] = False    # 正确显示负号

    # 定义模型名称和颜色
    subModel = ['subModel 1', 'subModel 2', 'subModel 3', 'subModel 4', 'subModel 5']
    model = ['Model a', 'Model b', 'Model c', 'Model d', 'Model e', 'Model f']
    colors = ['k', 'r', 'g', 'b', 'm', 'c']  # 黑、红、绿、蓝、洋红、青色

    # 创建图形和子图
    fig1, ax1 = plt.subplots()  # 应力-开度图像
    fig2, ax2 = plt.subplots()  # 应力-radius图像
    fig3, ax3 = plt.subplots()

    basePath = "D:\\Projects\\02_Innovation\\05_Data\\SoftCrack\\polygonal_data"
