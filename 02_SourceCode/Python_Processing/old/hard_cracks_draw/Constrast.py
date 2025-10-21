'''
# 1、在六组模型中，分别各选取一个子模型，绘制以下图像
# 绘制应力-平均aperture曲线和均一化后的图像
# 绘制应力-平均radius曲线
# 绘制应力-波速图（P波，S波）
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
model1Path = '.\\src\\dataProcess_draw\\data\\polygon_constrast_radius_aperture_record.json'


model1 = MainClass(dataPath=model1Path, name="三种AR对比模型")


# 确保数据是NumPy数组
model1ApertureRecord = model1.aperture_record        # (5, 20, 200, 6)
model1RadiusRecord = model1.radius_record

sx = model1.sx


# 图5：每组平均应力-波速图
fig5, axes5 = plt.subplots(figsize=(12, 8))
fig5.suptitle('Stress-Vp', fontsize=16)

model1V_dp = model1.average_velocity()

axes5.plot(sx, model1V_dp[:, 0], 'b-', label='0.01AR')
axes5.plot(sx, model1V_dp[:, 1], 'r-', label='0.1AR')
axes5.plot(sx, model1V_dp[:, 2], 'g-', label='原本的AR')

axes5.set_title('Stress-Vp')
axes5.set_xlabel('应力 (MPa)')
axes5.set_ylabel('平均P波速度 (m/s)')
axes5.legend()
axes5.grid(True)

fig5.tight_layout()  # 调整布局


# 图6：每组平均应力-aperture曲线
fig6, axes6 = plt.subplots(figsize=(12, 8))
fig6.suptitle('Stress-Aperture', fontsize=16)

model1ApertureRecord_Aver = np.mean(model1ApertureRecord, axis=(0, 1))  # 对第二维(20个裂缝)求平均

axes6.plot(sx, model1ApertureRecord_Aver[:, 0], 'b-', label='0.01AR')
axes6.plot(sx, model1ApertureRecord_Aver[:, 1], 'r-', label='0.1AR')
axes6.plot(sx, model1ApertureRecord_Aver[:, 2], 'g-', label='原本的AR')

axes6.set_title('Stress-Aperture')
axes6.set_xlabel('应力 (MPa)')
axes6.set_ylabel('平均aperture')
axes6.legend()
axes6.grid(True)

fig6.tight_layout()  # 调整布局


# 图7：每组平均应力-radius曲线
fig7, axes7 = plt.subplots(figsize=(12, 8))
fig7.suptitle('Stress-Radius', fontsize=16)

model1RadiusRecord_Aver = np.mean(model1RadiusRecord, axis=(0, 1))  # 对第二维(20个裂缝)求平均

axes7.plot(sx, model1RadiusRecord_Aver[:, 0], 'b-', label='0.01AR')
axes7.plot(sx, model1RadiusRecord_Aver[:, 1], 'r-', label='0.1AR')
axes7.plot(sx, model1RadiusRecord_Aver[:, 2], 'g-', label='原本的AR')

axes7.set_title('Stress-Radius')
axes7.set_xlabel('应力 (MPa)')
axes7.set_ylabel('平均radius')
axes7.legend()
axes7.grid(True)

fig7.tight_layout()  # 调整布局

plt.show()








