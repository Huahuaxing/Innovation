'''
加载comsol生成的六组模型数据结果
1、绘制应力-开度曲线
2、绘制应力-平均radius曲线
3、绘制应力-平均aperture曲线
4、将radius_record和aperture_record保存为json文件以便后续使用
'''

import numpy as np
import sys
import matplotlib.pyplot as plt
import json
import os

# 设置中文字体支持
plt.rcParams['font.sans-serif'] = ['SimHei']  # 使用黑体
plt.rcParams['axes.unicode_minus'] = False    # 正确显示负号

# 定义模型名称和颜色
subModel = ['subModel 1', 'subModel 2', 'subModel 3', 'subModel 4', 'subModel 5']
model = ['Model a', 'Model b', 'Model c', 'Model d', 'Model e', 'Model f']
colors = ['k', 'r', 'g', 'b', 'm', 'c']  # 黑、红、绿、蓝、洋红、青色

# 创建图形和子图
fig1, ax1 = plt.subplots()
fig2, ax2 = plt.subplots()
fig3, ax3 = plt.subplots()

dataType = 'ellipse_data'
dataPath = f'E:\\OneDrive\\Project\\InnovationLib\\Data\\SoftData\\{dataType}'

aa = np.zeros((40, 200, 43))
aperture = np.zeros((20, 200, 21))

aperture_random = np.zeros((5, 1, 200))
radius_random = np.zeros((5, 20, 200))
radius_record = np.zeros((5, 20, 200, 6))
aperture_record = np.zeros((5, 20, 200, 6))

# 加载1-1到1-5
for xd in range(1, 6):  # 五个模型
    for xs in range(1, 41):  # 四十个表格
        file_path = f'{dataPath}\\20-cracks-distance-1-{xd}-AR1\\20-cracks-distance-{xs}~40-{xd}-AR1.txt'
        aa[xs-1, :, :] = np.loadtxt(file_path, encoding='utf-8', skiprows=5)  # 1D：裂隙上下界面的点；2D：不同压力；3D：坐标值

    point_n = (aa.shape[2] - 1) // 2
    pointy_start_index = aa.shape[2] - (aa.shape[2] - 1) // 2    # aa数组第三维索引从22-42表示y坐标，共21个点

    for xs in range(0, 20):
        aperture[xs, :, :] = aa[2*xs, :, pointy_start_index:] - aa[2*xs+1, :, pointy_start_index:]
    
    # 将aperture数组中所有小于1e-7的值设置为0
    aperture[aperture < 1e-7] = 0

    percular = np.zeros((aa.shape[0], aa.shape[1], point_n))    # (20, 200, 21)
    radius = np.zeros((aa.shape[0]//2, aa.shape[1]))            # (20, 200)

    for xs in range(0, aperture.shape[0]):
        for xt in range(0, aperture.shape[1]):
            for xu in range(0, aperture.shape[2]):
                if aperture[xs, xt, xu] <= 1e-7:                # 设置一个阈值，小于判定为已闭合
                    percular[xs, xt, xu] = 1

            for xu in range(0, point_n-1):
                if percular[xs, xt, xu] * percular[xs, xt, xu+1] == 1:
                    cc = aa[2*xs, 0, xu+2] - aa[2*xs, 0, xu+1]      # 这里加2是因为aa数组第一列是应力，从第二列开始才是坐标
                    radius[xs, xt] = radius[xs, xt] + cc            # 这里radius存储裂隙已闭合的长度

            radius[xs, xt] = 0.036 - radius[xs, xt]
            # if radius[xs, xt] < 5e-5:
            #     radius[xs, xt] = 0

    aperture_aver = np.mean(aperture, axis=2)       # （20, 200）单个裂隙平均开度
    aperture_a = np.mean(aperture_aver, axis=0)     # （200）20个裂隙平均开度
    
    # 绘制压力-开度曲线
    ax1.plot(aa[0, :, 0], aperture_a, colors[xd-1], label=f'{subModel[xd-1]}')

    aperture_random[xd-1, :, :] = aperture_a                                    # （5, 1, 200），每个模型，每个应力条件下的平均开度
    radius_random[xd-1, :, :] = radius                                          # （5, 20, 200），每个模型，每个裂隙，每个应力条件下的长轴长度
    radius_record[xd-1, :, :, 0] = radius                                       # （5, 20, 200, 6），存储的是裂隙的长轴长度
    aperture_record[xd-1, :, :, 0] = (np.pi * 0.036 / 2) * aperture_aver        # （5, 20, 200, 6），存储的是裂隙的等效面积

# avera = np.zeros((5, 200))
# avera_aper = np.zeros((5, 200))

# for xs in range(0, 5):
#     for kk in range(0, 200):
#         avera[xs,kk] = np.mean(radius_random[xs,:,kk])         #  (5, 200)每个模型每个应力条件下，二十个裂隙的平均长轴长度
#         avera_aper[xs,kk] = sum(aperture_random[xs,:,kk])/20   # （5，200）？

# var = np.zeros(200)
# for kk in range(0, 200):
#     var[kk] = np.std(avera[:,kk])  # 每个应力条件下，五个模型的avera的标准差

# avera_aa = np.mean(avera,0)        # (200)，每个应力条件下，五个模型的avera的平均值
# avera_aperture = (np.pi * 0.036 / 2) * np.mean(avera_aper,0)

# bb = np.arange(1, 200, 10)          # 以10为步长，取应力数组
# ssx = np.squeeze(aa[0,bb,0])        # 应力数组

# ax2.plot(ssx, avera_aa[bb], 'c')
# ax3.plot(ssx, avera_aperture[bb], 'c')


# 加载3-1到6-5 部分
ARList = ['4AR1+16AR2', '8AR1+12AR2', '12AR1+8AR2', '16AR1+4AR2']
for xe in range(3, 7):
    for xd in range(1, 6):
        for xs in range(1, 41):
            file_path = f'{dataPath}\\20-cracks-distance-{xe}-{xd}-AR1+AR2\\20-cracks-distance-{xs}~40-{xd}-AR1+AR2.txt'
            aa[xs-1, :, :] = np.loadtxt(file_path, encoding='utf-8', skiprows=5)
        
        point_n = (aa.shape[2] - 1) // 2
        pointy_start = aa.shape[2] - (aa.shape[2] - 1) // 2
        
        for xs in range(1, 21):
            aperture[xs-1, :, :] = aa[2*xs-2, :, pointy_start:] - aa[2*xs-1, :, pointy_start:]
        
        aperture[aperture <= 1e-7] = 0
        
        percular = np.zeros((aa.shape[0], aa.shape[1], point_n))
        radius = np.zeros((aa.shape[0]//2, aa.shape[1]))
        
        for xs in range(0, aperture.shape[0]):
            for xt in range(0, aperture.shape[1]):
                for xu in range(0, aperture.shape[2]):
                    if aperture[xs, xt, xu] <= 1e-7:                # 设置一个阈值，小于判定为已闭合
                        percular[xs, xt, xu] = 1

                for xu in range(0, point_n-1):
                    if percular[xs, xt, xu] * percular[xs, xt, xu+1] == 1:
                        cc = aa[2*xs, 0, xu+2] - aa[2*xs, 0, xu+1]      # 这里加2是因为aa数组第一列是应力，从第二列开始才是坐标
                        radius[xs, xt] = radius[xs, xt] + cc            # 这里radius存储裂隙已闭合的长度

                radius[xs, xt] = 0.036 - radius[xs, xt]
                # if radius[xs, xt] < 5e-5:
                #     radius[xs, xt] = 0
        
        aperture_aver = np.sum(aperture, axis=2) / point_n
        aperture_a = np.sum(aperture_aver, axis=0) / 20
        
        # 绘制压力-开度曲线
        ax1.plot(aa[0, :, 0], aperture_a, colors[xd-1], label=f'{subModel[xd-1]}')
        
        aperture_random[xd-1, :, :] = aperture_a
        radius_random[xd-1, :, :] = radius
        radius_record[xd-1, :, :, xe-2] = radius
        aperture_record[xd-1, :, :, xe-2] = (np.pi * 0.036 / 2) * aperture_aver
    
    # # 计算平均值
    # for xs in range(5):
    #     for kk in range(200):
    #         avera[xs, kk] = np.sum(radius_random[xs, :, kk]) / 20
    #         avera_aper[xs, kk] = np.sum(aperture_random[xs, :, kk]) / 20
    
    # # 计算标准差
    # for kk in range(200):
    #     var[kk] = np.std(avera[:, kk])
    
    # avera_aa = np.sum(avera, axis=0) / 5
    # avera_aperture = (np.pi * 0.036 / 2) * np.sum(avera_aper, axis=0) / 5
    
    # bb = np.arange(0, 200, 10)
    # ssx = np.squeeze(aa[0, bb, 0])
    
    # ax2.plot(ssx, avera_aa[bb])
    
    # ax3.plot(ssx, avera_aperture[bb])


# 加载2-1到2-5
for xd in range(1, 6):
    for xs in range(1, 41):
        file_path = f'{dataPath}\\20-cracks-distance-2-{xd}-AR2\\20-cracks-distance-{xs}~40-{xd}-AR2.txt'
        aa[xs-1, :, :] = np.loadtxt(file_path, encoding='utf-8', skiprows=5)
    
    point_n = (aa.shape[2] - 1) // 2
    pointy_start = aa.shape[2] - (aa.shape[2] - 1) // 2
    
    for xs in range(1, 21):
        aperture[xs-1, :, :] = aa[2*xs-2, :, pointy_start:] - aa[2*xs-1, :, pointy_start:]
    
    aperture[aperture <= 1e-7] = 0
    
    percular = np.zeros((aa.shape[0], aa.shape[1], point_n))
    radius = np.zeros((aa.shape[0]//2, aa.shape[1]))
    
    for xs in range(0, aperture.shape[0]):
        for xt in range(0, aperture.shape[1]):
            for xu in range(0, aperture.shape[2]):
                if aperture[xs, xt, xu] <= 1e-7:                # 设置一个阈值，小于判定为已闭合
                    percular[xs, xt, xu] = 1

            for xu in range(0, point_n-1):
                if percular[xs, xt, xu] * percular[xs, xt, xu+1] == 1:
                    cc = aa[2*xs, 0, xu+2] - aa[2*xs, 0, xu+1]      # 这里加2是因为aa数组第一列是应力，从第二列开始才是坐标
                    radius[xs, xt] = radius[xs, xt] + cc            # 这里radius存储裂隙已闭合的长度

            radius[xs, xt] = 0.036 - radius[xs, xt]
            # if radius[xs, xt] < 5e-5:
            #     radius[xs, xt] = 0
    
    aperture_aver = np.sum(aperture, axis=2) / point_n
    aperture_a = np.sum(aperture_aver, axis=0) / 20
    
    ax1.plot(aa[0, :, 0], aperture_a, colors[xd-1], label=f'{subModel[xd-1]}')
    
    aperture_random[xd-1, :, :] = aperture_a
    radius_random[xd-1, :, :] = radius
    radius_record[xd-1, :, :, 5] = radius  # 在Python中索引是5
    aperture_record[xd-1, :, :, 5] = (np.pi * 0.036 / 2) * aperture_aver

# # 计算平均值
# for xs in range(5):
#     for kk in range(200):
#         avera[xs, kk] = np.sum(radius_random[xs, :, kk]) / 20
#         avera_aper[xs, kk] = np.sum(aperture_random[xs, :, kk]) / 20

# # 计算标准差
# for kk in range(200):
#     var[kk] = np.std(avera[:, kk])

# avera_aa = np.sum(avera, axis=0) / 5
# avera_aperture = (np.pi * 0.036 / 2) * np.sum(avera_aper, axis=0) / 5

# bb = np.arange(0, 200, 10)
# ssx = np.squeeze(aa[0, bb, 0])

# ax2.plot(ssx, avera_aa[bb], 'r')

# ax3.plot(ssx, avera_aperture[bb], 'r')

sx = np.squeeze(aa[0, :, 0])

# # 设置图形属性
# # fig1设置（压力-开度曲线）
# fig1.legend(subModel)
# fig1.suptitle('五个子模型压力-开度曲线')
# ax1.set_ylabel('Aperture (m)', fontsize=12)
# ax1.set_xlabel('Pressure (Pa)', fontsize=12)  # 只在底部子图设置x轴标签
# fig1.set_size_inches(25/2.54, 35/2.54)  # 厘米转英寸

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

# plt.tight_layout()
# plt.show()  # 显示所有图形


# 将radius_record和aperture_record保存为json文件
def save_arrays_to_json():
    # 创建要保存的字典
    data_dict = {
        "radius_record": radius_record.tolist(),
        "aperture_record": aperture_record.tolist(),
        "sx": sx.tolist()  # 也保存应力数组以便后续使用
    }
    
    # 保存为JSON文件
    with open(f'E:\OneDrive\Project\Innovation\Data\\{dataType}_radius_aperture_record2.json', 'w') as f:
        json.dump(data_dict, f)
    
    print(f"{dataType}数据已保存为JSON文件")

# 调用函数保存数据
save_arrays_to_json()
