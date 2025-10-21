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

dataType = 'polygon_constrast'
dataPath = f'E:\\OneDrive\\Project\\InnovationLib\\Data\\{dataType}'

aa = np.zeros((40, 200, 43))
aperture = np.zeros((20, 200, 21))

aperture_random = np.zeros((5, 1, 200))
radius_random = np.zeros((5, 20, 200))
radius_record = np.zeros((5, 20, 200, 6))
aperture_record = np.zeros((5, 20, 200, 6))


# 加载三种不同AR的数据
index = 0
for i in ['0.01AR', '0.1AR']:
    for xd in range(1, 6):  # 五个模型
        for xs in range(1, 41):  # 四十个表格
            file_path = f'{dataPath}\\{i}_20-cracks-distance-6-{xd}-16AR4+4AR2\\20-cracks-distance-{xs}~40-{xd}-16AR4+4AR2.txt'
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
        radius_record[xd-1, :, :, index] = radius                                       # （5, 20, 200, 6），存储的是裂隙的长轴长度
        aperture_record[xd-1, :, :, index] = (np.pi * 0.036 / 2) * aperture_aver        # （5, 20, 200, 6），存储的是裂隙的等效面积
    
    index += 1
    print(f'{i}数据加载完成, 当前index为{index}')


for xd in range(1, 6):  # 五个模型
    for xs in range(1, 41):  # 四十个表格
        file_path = f'{dataPath}\\20-cracks-distance-6-{xd}-16AR1+4AR2\\20-cracks-distance-{xs}~40-{xd}-16AR1+4AR2.txt'
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
    radius_record[xd-1, :, :, index] = radius                                       # （5, 20, 200, 6），存储的是裂隙的长轴长度
    aperture_record[xd-1, :, :, index] = (np.pi * 0.036 / 2) * aperture_aver        # （5, 20, 200, 6），存储的是裂隙的等效面积

print(f'AR1数据加载完成, 当前index为{index}, radius_record.shape为{radius_record.shape}, aperture_record.shape为{aperture_record.shape}')

# 将radius_record和aperture_record保存为json文件
sx = np.squeeze(aa[0, :, 0])
def save_arrays_to_json():
    # 创建要保存的字典
    data_dict = {
        "radius_record": radius_record.tolist(),
        "aperture_record": aperture_record.tolist(),
        "sx": sx.tolist()  # 也保存应力数组以便后续使用
    }
    
    # 保存为JSON文件
    with open(f'E:\\OneDrive\\Project\\Innovation\\src\\dataProcess_draw\\{dataType}_radius_aperture_record.json', 'w') as f:
        json.dump(data_dict, f)
    
    print(f"{dataType}数据已保存为JSON文件")

# 调用函数保存数据
save_arrays_to_json()
