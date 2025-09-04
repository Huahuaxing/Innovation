'''
1、在六组模型中，分别各选取一个子模型，绘制以下图像
绘制应力-平均aperture曲线和均一化后的图像
绘制应力-平均radius曲线
绘制应力-波速图（P波，S波）
2、fig5, 将六组模型平均掉，绘制平均的应力-波速图（P波，S波）
3、fig6,fig7, 将五个子模型平均，绘制每组应力-radius曲线和aperture曲线
'''
import numpy as np
import matplotlib.pyplot as plt
import sys
from MainClass import MainClass

plt.rcParams['font.sans-serif'] = ['SimHei']  # 使用黑体
plt.rcParams['axes.unicode_minus'] = False    # 正确显示负号


# 加载数据
# model1Path = '.\\Data\\ellipse_data_radius_aperture_record.json'
model2Path = '.\\05_ProcessedData\\record\\ellipse_data_aligned_radius_aperture_record.json'
model3Path = '.\\05_ProcessedData\\record\\polygonal_data_radius_aperture_record.json'

# model1 = MainClass(dataPath=model1Path)
model2 = MainClass(dataPath=model2Path)
model3 = MainClass(dataPath=model3Path)

# 确保数据是NumPy数组
# model1ApertureRecord = model1.aperture_record        # (5, 20, 200, 6)
# model1RadiusRecord = model1.radius_record
model2ApertureRecord = model2.aperture_record
model2RadiusRecord = model2.radius_record
model3ApertureRecord = model3.aperture_record
model3RadiusRecord = model3.radius_record
sx = model2.sx
tick_indices = np.arange(0, len(sx), 20)
tick_indices = np.append(tick_indices, 199)
indices = [0, 4, 3, 2, 1, 5]
indices2 = [0, 1, 2, 3, 4, 5]
titles = ['20AR1', '16AR1+4AR2', '12AR1+8AR2', '8AR1+12AR2', '4AR1+16AR2', '20AR2']


# 图1：子模型应力-aperture曲线
# fig1, axes1 = plt.subplots(2, 3, sharex=True, sharey=True, figsize=(12, 8))
# fig1.suptitle('子模型应力-aperture曲线', fontsize=16)

# model1AperRecord_aver = np.mean(model1AperRecord, axis=1)  # 对第二维(20个裂缝)求平均
# model2AperRecord_aver = np.mean(model2AperRecord, axis=1)
# model3AperRecord_aver = np.mean(model3AperRecord, axis=1)

# for i in range(axes1.shape[0]):
#     for j in range(axes1.shape[1]):
#         index = i * 3 + j
#         axes1[i, j].plot(sx, model1AperRecord_aver[1, :, indices[index]], 'b--', label='椭圆形未对齐裂缝')
#         axes1[i, j].plot(sx, model2AperRecord_aver[1, :, indices[index]], 'r-', label='椭圆形对齐裂缝')
#         axes1[i, j].plot(sx, model3AperRecord_aver[1, :, indices[index]], 'g-', label='多边形裂缝')
#         axes1[i, j].set_title(titles[index])
#         axes1[i, j].set_xlabel('应力 (MPa)')
#         axes1[i, j].set_ylabel('aperture')
#         axes1[i, j].legend()
#         axes1[i, j].grid(True)

# fig1.tight_layout()  # 调整布局


# 图2：归一化的子模型应力-aperture曲线


# 图3：子模型应力-radius曲线
# fig3, axes3 = plt.subplots(2, 3, sharex=True, sharey=True, figsize=(12, 8))
# fig3.suptitle('子模型应力-radius曲线', fontsize=16)

# # 计算平均值
# model1RadiuRecord_aver = np.mean(model1RadiuRecord, axis=1)  # 对第二维(20个裂缝)求平均
# model2RadiuRecord_aver = np.mean(model2RadiuRecord, axis=1)
# model3RadiuRecord_aver = np.mean(model3RadiuRecord, axis=1)

# for i in range(axes3.shape[0]):
#     for j in range(axes3.shape[1]):
#         index = i * 3 + j
#         new_index = indices[index]
#         axes3[i, j].plot(sx, model1RadiuRecord_aver[1, :, indices[index]], 'b--', label='椭圆形未对齐裂缝')
#         axes3[i, j].plot(sx, model2RadiuRecord_aver[1, :, indices[index]], 'r-', label='椭圆形对齐裂缝')
#         axes3[i, j].plot(sx, model3RadiuRecord_aver[1, :, indices[index]], 'g-', label='多边形裂缝')
#         axes3[i, j].set_title(titles[index])
#         axes3[i, j].set_xlabel('应力 (MPa)')
#         axes3[i, j].set_ylabel('radius')
#         axes3[i, j].legend()
#         axes3[i, j].grid(True)

# fig3.tight_layout()  # 调整布局


# 图4：每组第n个子模型stress-velocity图
# fig4, axes4 = plt.subplots(2, 3, sharex=True, sharey=True, figsize=(12, 8))
# fig4.suptitle('子模型stress-velocity图', fontsize=16)

# model1SingleV_dp = model1.single_stress_velocity(1)
# model2SingleV_dp = model2.single_stress_velocity(1)
# model3SingleV_dp = model3.single_stress_velocity(1)

# for i in range(axes3.shape[0]):
#     for j in range(axes3.shape[1]):
#         index = i * 3 + j
#         new_index = indices[index]
#         axes4[i, j].plot(sx, model1SingleV_dp[:, indices[index]], 'b--', label='椭圆形未对齐裂缝')
#         axes4[i, j].plot(sx, model2SingleV_dp[:, indices[index]], 'r-', label='椭圆形对齐裂缝')
#         axes4[i, j].plot(sx, model3SingleV_dp[:, indices[index]], 'g-', label='多边形裂缝')
#         axes4[i, j].set_title(titles[index])
#         axes4[i, j].set_xlabel('应力 (MPa)')
#         axes4[i, j].set_ylabel('子模型2-P波速度 (m/s)')
#         axes4[i, j].legend()
#         axes4[i, j].grid(True)

# fig4.tight_layout()  # 调整布局


# # 图5：每组平均应力-波速图
# fig5, axes5 = plt.subplots(2, 3, sharex=True, sharey=True, figsize=(12, 8))
# fig5.suptitle('Stress-Vp', fontsize=16)

# model1V_dp = model1.average_velocity()
# model2V_dp = model2.average_velocity()
# model3V_dp = model3.average_velocity()

# for i in range(axes5.shape[0]):
#     for j in range(axes5.shape[1]):
#         index = i * 3 + j
#         new_index = indices[index]
#         axes5[i, j].plot(sx, model1V_dp[0, :, indices2[index]], 'b--', label='椭圆形未对齐裂缝')
#         axes5[i, j].plot(sx, model2V_dp[0, :, indices[index]], 'r-', label='椭圆形对齐裂缝')
#         axes5[i, j].plot(sx, model3V_dp[0, :, indices[index]], 'g-', label='多边形裂缝')
#         axes5[i, j].set_xticks(sx[tick_indices])
#         axes5[i, j].set_title(titles[index])
#         axes5[i, j].set_xlabel('应力 (MPa)')
#         axes5[i, j].set_ylabel('平均P波速度 (m/s)')
#         axes5[i, j].legend()
#         axes5[i, j].grid(True)

# fig5.tight_layout()  # 调整布局


# # 图6：每组平均应力-aperture曲线
# fig6, axes6 = plt.subplots(2, 3, sharex=True, sharey=True, figsize=(12, 8))
# fig6.suptitle('Stress-Aperture', fontsize=16)

# model1ApertureRecord_Aver = np.mean(model1ApertureRecord, axis=(0, 1))  # 对第二维(20个裂缝)求平均
# model2ApertureRecord_Aver = np.mean(model2ApertureRecord, axis=(0, 1))
# model3ApertureRecord_Aver = np.mean(model3ApertureRecord, axis=(0, 1))

# for i in range(axes6.shape[0]):
#     for j in range(axes6.shape[1]):
#         index = i * 3 + j
#         new_index = indices[index]
#         axes6[i, j].plot(sx, model1ApertureRecord_Aver[:, indices2[index]], 'b--', label='椭圆形未对齐裂缝')
#         axes6[i, j].plot(sx, model2ApertureRecord_Aver[:, indices[index]], 'r-', label='椭圆形对齐裂缝')
#         axes6[i, j].plot(sx, model3ApertureRecord_Aver[:, indices[index]], 'g-', label='多边形裂缝')
#         axes6[i, j].set_xticks(sx[tick_indices])
#         axes6[i, j].set_title(titles[index])
#         axes6[i, j].set_xlabel('应力 (MPa)')
#         axes6[i, j].set_ylabel('平均aperture')
#         axes6[i, j].legend()
#         axes6[i, j].grid(True)

# fig6.tight_layout()  # 调整布局


# # 图7：每组平均应力-radius曲线
# fig7, axes7 = plt.subplots(2, 3, sharex=True, sharey=True, figsize=(12, 8))
# fig7.suptitle('Stress-Radius', fontsize=16)

# model1RadiusRecord_Aver = np.mean(model1RadiusRecord, axis=(0, 1))  # 对第二维(20个裂缝)求平均
# model2RadiusRecord_Aver = np.mean(model2RadiusRecord, axis=(0, 1))
# model3RadiusRecord_Aver = np.mean(model3RadiusRecord, axis=(0, 1))

# for i in range(axes7.shape[0]):
#     for j in range(axes7.shape[1]):
#         index = i * 3 + j
#         new_index = indices[index]
#         axes7[i, j].plot(sx, model1RadiusRecord_Aver[:, indices2[index]], 'b--', label='椭圆形未对齐裂缝')
#         axes7[i, j].plot(sx, model2RadiusRecord_Aver[:, indices[index]], 'r-', label='椭圆形对齐裂缝')
#         axes7[i, j].plot(sx, model3RadiusRecord_Aver[:, indices[index]], 'g-', label='多边形裂缝')
#         axes7[i, j].set_xticks(sx[tick_indices])
#         axes7[i, j].set_title(titles[index])
#         axes7[i, j].set_xlabel('应力 (MPa)')
#         axes7[i, j].set_ylabel('平均radius')
#         axes7[i, j].legend()
#         axes7[i, j].grid(True)

# fig7.tight_layout()  # 调整布局


# 以下三张图，应曹老师要求，去除蓝色虚线，子图名“20AR1”等放入图片内部，新子图名改为(a)，(b)，(c)的形式
# fig8, axes8 = plt.subplots(2, 3, sharex=True, sharey=True, figsize=(12, 8))
# fig8.suptitle('Stress-Vp', fontsize=16)

# model2V = model2.average_velocity()
# model3V = model3.average_velocity()

# for i in range(axes8.shape[0]):
#     for j in range(axes8.shape[1]):
#         index = i * 3 + j
#         new_index = indices[index]

#         # 绘制曲线
#         axes8[i, j].plot(sx, model2V[0, :, indices[index]], 'r-', label='椭圆形对齐裂缝')
#         axes8[i, j].plot(sx, model3V[0, :, indices[index]], 'g-', label='多边形裂缝')
        
#         # 设置 x 轴刻度
#         axes8[i, j].set_xticks(sx[tick_indices])
        
#         # 设置编号
#         axes8[i, j].set_title(f'({chr(97 + index)})')  # 使用字母编号

#         # 在子图内部添加原标题，调整 y 坐标并使用 bbox
#         axes8[i, j].text(0.05, 0.95, titles[index], ha='left', va='top', 
#                          transform=axes8[i, j].transAxes,
#                          bbox=dict(facecolor='white', alpha=0.5, edgecolor='black'))  # 添加背景
        
#         axes8[i, j].set_xlabel('应力 (MPa)')
#         axes8[i, j].set_ylabel('平均P波速度 (m/s)')
#         axes8[i, j].legend()
#         axes8[i, j].grid(True)

# fig8.tight_layout()  # 调整布局


# # 平均应力-Aperture曲线
# fig9, axes9 = plt.subplots(2, 3, sharex=True, sharey=True, figsize=(12, 8))
# fig9.suptitle('Stress-Aperture', fontsize=16)

# model2ApertureRecord_Aver = np.mean(model2ApertureRecord, axis=(0, 1))
# model3ApertureRecord_Aver = np.mean(model3ApertureRecord, axis=(0, 1))

# for i in range(axes9.shape[0]):
#     for j in range(axes9.shape[1]):
#         index = i * 3 + j
#         new_index = indices[index]

#         # 绘制曲线
#         axes9[i, j].plot(sx, model2ApertureRecord_Aver[:, indices[index]], 'r-', label='椭圆形对齐裂缝')
#         axes9[i, j].plot(sx, model3ApertureRecord_Aver[:, indices[index]], 'g-', label='多边形裂缝')
        
#         # 设置 x 轴刻度
#         axes9[i, j].set_xticks(sx[tick_indices])
        
#         # 设置编号
#         axes9[i, j].set_title(f'({chr(97 + index)})')  # 使用字母编号
        
#         # 在子图内部添加原标题
#         axes9[i, j].text(0.95, 0.75, titles[index], ha='right', va='top', transform=axes9[i, j].transAxes,
#                          bbox=dict(facecolor='white', alpha=0.5, edgecolor='black'))

#         axes9[i, j].set_xlabel('应力 (MPa)')
#         axes9[i, j].set_ylabel('平均Aperture')
#         axes9[i, j].legend()
#         axes9[i, j].grid(True)

# fig9.tight_layout()  # 调整布局


# # 图10：每组平均应力-radius曲线
# fig10, axes10 = plt.subplots(2, 3, sharex=True, sharey=True, figsize=(12, 8))
# fig10.suptitle('Stress-Radius', fontsize=16)

# model2RadiusRecord_Aver = np.mean(model2RadiusRecord, axis=(0, 1))
# model3RadiusRecord_Aver = np.mean(model3RadiusRecord, axis=(0, 1))

# for i in range(axes10.shape[0]):
#     for j in range(axes10.shape[1]):
#         index = i * 3 + j
#         new_index = indices[index]

#         # 绘制曲线
#         axes10[i, j].plot(sx, model2RadiusRecord_Aver[:, indices[index]], 'r-', label='椭圆形对齐裂缝')
#         axes10[i, j].plot(sx, model3RadiusRecord_Aver[:, indices[index]], 'g-', label='多边形裂缝')
        
#         # 设置 x 轴刻度
#         axes10[i, j].set_xticks(sx[tick_indices])
        
#         # 设置编号
#         axes10[i, j].set_title(f'({chr(97 + index)})')  # 使用字母编号
        
#         # 在子图内部添加原标题
#         axes10[i, j].text(0.95, 0.75, titles[index], ha='right', va='top', transform=axes10[i, j].transAxes,
#                          bbox=dict(facecolor='white', alpha=0.5, edgecolor='black'))

#         axes10[i, j].set_xlabel('应力 (MPa)')
#         axes10[i, j].set_ylabel('平均Raius')
#         axes10[i, j].legend()
#         axes10[i, j].grid(True)

# fig10.tight_layout()  # 调整布局


# 图11：每组平均应力-SH波速度图
fig11, axes11 = plt.subplots(2, 3, sharex=True, sharey=True, figsize=(12, 8))
fig11.suptitle('Stress-Vsh', fontsize=16)

model2Vsh = model2.average_velocity(16)[2, :, :]
model3Vsh = model3.average_velocity(16)[2, :, :]

for i in range(axes11.shape[0]):
    for j in range(axes11.shape[1]):
        index = i * 3 + j
        new_index = indices[index]

        # 绘制曲线
        axes11[i, j].plot(sx, model2Vsh[:, indices[index]], 'r-', label='椭圆形对齐裂缝')
        axes11[i, j].plot(sx, model3Vsh[:, indices[index]], 'g-', label='多边形裂缝')
        
        # 设置 x 轴刻度
        axes11[i, j].set_xticks(sx[tick_indices])
        axes11[i, j].ticklabel_format(style='plain', axis='y')
        
        # 设置编号
        axes11[i, j].set_title(f'({chr(97 + index)})')  # 使用字母编号

        # 在子图内部添加原标题，调整 y 坐标并使用 bbox
        axes11[i, j].text(0.05, 0.95, titles[index], ha='left', va='top', 
                         transform=axes11[i, j].transAxes,
                         bbox=dict(facecolor='white', alpha=0.5, edgecolor='black'))  # 添加背景
        
        axes11[i, j].set_xlabel('应力 (MPa)')
        axes11[i, j].set_ylabel('平均SH波速度 (m/s)')
        axes11[i, j].legend()
        axes11[i, j].grid(True)

fig11.tight_layout()  # 调整布局

np.savetxt('.\\05_ProcessedData\\velocity\\90_degree\\vsh_ellipse.csv', model2Vsh, delimiter=',')
np.savetxt('.\\05_ProcessedData\\velocity\\90_degree\\vsh_polygonal.csv', model3Vsh, delimiter=',')


plt.show()








