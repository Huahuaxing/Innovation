import numpy as np
import matplotlib.pyplot as plt
from scipy.io import loadmat
import scipy.io
import sys

from utils.modulus_dry import modulus_dry
from utils.modulus_dry_inclined import modulus_dry_inclined
from utils.modulus_dry_stress import modulus_dry_stress

# chr = r'D:\001 Research\paper\paper 008\data\model_random_18_distance_{}.txt'.format(xs)
# chr=['D:\BaiduSyncdisk\paper 004\matlab\radius.mat'];
# 1D，裂隙上下界面的点；2D，表示不同的压力；3D表示该点的坐标，（21：39）表示Y坐标；
# 这里可以根据需要访问 data 中的变量
# 例如，如果 .mat 文件中有一个名为 'variable_name' 的变量，可以这样访问：
# variable_data = data['variable_name']
dataPath = 'D:\\OneDrive\\Project\\Innovation'
filePath = f'{dataPath}\\src\\matlab\\matlab_20_cracks_aperture_and_radius.mat'
data = loadmat(filePath)
aperture_record = data['aperture_record']      # aperture_record.shape = (5, 20, 200, 6)
radius_record = data['radius_record']          # radius_record.shape = (5, 20, 200, 6)
sx = data['sx']                                # sx.shape = (1, 200)
sx = sx[0]


if __name__ == '__main__':

    colors = ['r', 'k', 'c', 'g', 'm', 'b']
    plt.rcParams['font.family'] = 'Times New Roman'

    # TI背景介质下
    n = 1                           # 裂隙的个数
    C = np.zeros((6, 6))            # 弹性矩阵
    C_iso = np.zeros((2, 2))        # 各向同性介质下的弹性矩阵 

    backProperty = 2                # 1表示anisotropic,2表示isotropic
    dimention = 3                   # 2表示2D，3表示3D
    K = 4.829e9
    MU = 3.180e9

    if backProperty == 1:
        C[0, 0] = 47.31e9
        C[2, 2] = 33.89e9
        C[0, 1] = 7.83e9
        C[0, 2] = 5.29e9
        C[3, 3] = 17.15e9
        C[1, 1] = C[0, 0]
        C[1, 2] = C[0, 2]
        C[5, 5] = 0.5 * (C[0, 0] - C[0, 1])
        C[4, 4] = C[3, 3]
        C[1, 0] = C[0, 1]
        C[2, 0] = C[0, 2]
        C[2, 1] = C[1, 2]
    elif backProperty == 2:
        C_iso[0, 0] = K + 4 * MU / 3.0
        C_iso[0, 1] = K - 2 * MU / 3.0  # for zizhen
        # C_iso[0, 0] = 6.292e9
        # C_iso[0, 1] = 3.692e9  # for zizhen
        C[0, 0] = C_iso[0, 0]
        C[0, 1] = C_iso[0, 1]
        C[0, 2] = C[0, 1]
        C[1, 0] = C[0, 2]
        C[1, 1] = C[0, 0]
        C[1, 2] = C[1, 0]
        C[2, 0] = C[0, 2]
        C[2, 1] = C[1, 0]
        C[2, 2] = C[1, 1]
        C[5, 5] = 0.5 * (C[0, 0] - C[0, 1])
        C[4, 4] = C[5, 5]
        C[3, 3] = C[5, 5]

    # c_density = 0.05
    # c_as = 0.01  # for 59-1490

    # 创建 sita 数组
    sita = np.linspace(0, np.pi, 31)  # sita.shape = (31,)

    density = 2.504e3

    V_dry = np.zeros((3, sita.size))  # V_dry.shape = (3, 31) [0]P,[1]SV,[2]SH  
    V_saturated = np.zeros((3, sita.size))
    angle = 0

    V_dry_oblique = np.zeros((3, sita.size))
    V_saturated_oblique = np.zeros((3, sita.size))

    C_eff = np.zeros((200, 5, 6, 6, 6))  # 这里的第四个维度的6，代表的更多是AR1, AR2，以及AR1+AR2

    for xd in range(6):
        for xa in range(200):
            for xc in range(5):
                Z_intermediate = np.zeros((6, 6))
                for xb in range(20):

                    a1 = 4.64e-1
                    a2 = radius_record[xc, xb, xa, xd]  # 这个代表的是长轴的，表示的半轴的长度，单位是m
                    a3 = aperture_record[xc, xb, xa, xd] * 2 / np.pi
                    c_as = a3 / a2
                    angle = 0

                    S_mian = 20 * 20 * 10**(-4)  # 这个表示的是单元体的面积

                    if dimention == 2:
                        c_density = n * (a2**2) / S_mian
                        p = n * np.pi * a2 * a3 / S_mian  # 这个是柱体条件下的（2D）crack porosity   
                    elif dimention == 3:
                        c_density = n * (a2**3) / S_mian
                        p = 4 * np.pi * c_density * c_as / 3.0  # 这个是椭圆条件下的（3D）crack porosity

                    c_filling = 2.25e9

                    c_1 = np.sqrt(C[0, 0] * C[2, 2])  # 注意 Python 的索引从 0 开始

                    B = np.zeros(6)  # 初始化 B 数组
                    B[2] = np.sqrt(C[5, 5] / C[3, 3])
                    B[3] = np.sqrt((c_1 - C[0, 2]) * (c_1 + C[0, 2] + 2 * C[3, 3]) / (C[2, 2] * C[3, 3]))
                    B[4] = np.sqrt((c_1 + C[0, 2]) * (c_1 - C[0, 2] - 2 * C[3, 3]) / (C[2, 2] * C[3, 3]))
                    B[0] = 0.5 * (B[3] + B[4])
                    B[1] = 0.5 * (B[3] - B[4])

                    Z, V_dry_oblique = modulus_dry_inclined(c_density, B, c_1, C, angle, density, sita)
                    Z_intermediate = Z + Z_intermediate         # Z.shape = (6, 6), Z_intermediate.shape = (6, 6)

                S = np.linalg.inv(C) + Z_intermediate
                C_eff[xa, xc, :, :, xd] = np.linalg.inv(S)

    fig1, ax1 = plt.subplots()
    for i in range(6):
        ax1.plot(sx, C_eff[:, 1, 2, 2, i], colors[i], label=f'Model {chr(97+i)}')
    ax1.legend()
    ax1.set_xlabel('Stress (Pa)', fontsize=12)
    ax1.set_ylabel(r'$C_{33} \, (Pa)$', fontsize=12)

    # 取两个特定的应力条件（第20个，第40个），绘制干燥状态下的角度-波速图（P波，S波）
    C = np.zeros((6, 6))
    for ak in range(6):
        for aa in range(6):
            for ab in range(6):
                C[aa, ab] = np.sum(C_eff[20, :, aa, ab, ak]) / 5

    # 计算干燥状态下的波速
    V_dry, CC = modulus_dry(c_1, sita, C, density, a1, a2, a3, p)   # V_dry.shape = (3, 31) [0]P,[1]SV,[2]SH    

    # 绘制 P-wave velocity
    fig2, ((ax2, ax3), (ax4, ax5)) = plt.subplots(2, 2)
    ax2.plot(sita, V_dry[0, :])
    ax2.legend(['Model a', 'Model b', 'Model c', 'Model d', 'Model e', 'Model f'])
    ax2.set_xlabel('Angle (Rad)', fontsize=12)
    ax2.set_ylabel('P-wave velocity (m/s)', fontsize=12)

    # 绘制 SV-wave velocity
    ax4.plot(sita, V_dry[1, :])
    ax4.legend(['Model a', 'Model b', 'Model c', 'Model d', 'Model e', 'Model f'])
    ax4.set_xlabel('Angle (Rad)', fontsize=12)
    ax4.set_ylabel('SV-wave velocity (m/s)', fontsize=12)

    # 更新C矩阵
    for ak in range(6):
        for aa in range(6):
            for ab in range(6):
                C[aa, ab] = np.sum(C_eff[40, :, aa, ab, ak]) / 5  # 计算 C 矩阵的值

    # 重新计算干燥状态下的波速
    V_dry, CC = modulus_dry(c_1, sita, C, density, a1, a2, a3, p)   # V_dry.shape = (3, 31)

    # 绘制第二组 P-wave velocity
    ax3.plot(sita, V_dry[0, :])  # P-wave velocity
    ax3.legend(['Model a', 'Model b', 'Model c', 'Model d', 'Model e', 'Model f'])
    ax3.set_xlabel('Angle (Rad)', fontsize=12)
    ax3.set_ylabel('P-wave velocity (m/s)', fontsize=12)

    # 绘制第二组 SV-wave velocity
    ax5.plot(sita, V_dry[1, :])  # S-wave velocity
    ax5.legend(['Model a', 'Model b', 'Model c', 'Model d', 'Model e', 'Model f'])
    ax5.set_xlabel('Angle (Rad)', fontsize=12)
    ax5.set_ylabel('SV-wave velocity (m/s)', fontsize=12)


    # 这里以下的部分，是同一个方向，但是不同压力下对应的波速
    # 绘制应力-波速图
    fig3, (ax6, ax7) = plt.subplots(1, 2)

    intermediate_C = np.sum(C_eff, axis=1) / 5
    V_dp = np.zeros((200, 6))
    V_ds = np.zeros((200, 6))

    # 处理每个模型
    for ak in range(6):
        C_stress = intermediate_C[:, :, :, ak]  # C_eff的维度是(200,5,6,6,6)
        for am in range(200):
            C = C_stress[am, :, :]
            V_dry, CC = modulus_dry_stress(c_1, sita, C, density, a1, a2, a3, p, B, c_density)
            V_dp[am, ak] = V_dry[0, 0]  # am表示压力，ak表示AR1,AR2,AR1+AR2
            V_ds[am, ak] = V_dry[1, 7]  # 注意Python索引从0开始，所以这里是7而不是8
        
        ax6.plot(sx, V_dp[:, ak])
        ax7.plot(sx, V_ds[:, ak])

    # 处理dash_velocity_model
    dash_velocity_model_f = np.zeros(sx.shape)
    dash_velocity_model_a = np.zeros(sx.shape)

    # 设置P波速度的分段函数
    dash_velocity_model_f[0:27] = V_dp[0, 5]  # Python索引从0开始
    dash_velocity_model_f[27:len(sx)] = V_dp[199, 5]  # 使用199代替MATLAB中的200
    dash_velocity_model_a[0:54] = V_dp[0, 5]
    dash_velocity_model_a[54:len(sx)] = V_dp[199, 5]

    # 绘制P波速度
    ax6.plot(sx, dash_velocity_model_a, 'k:', label='Model a-ana')
    ax6.plot(sx, dash_velocity_model_f, 'r:', label='Model f-ana')

    # 设置S波速度的分段函数
    dash_velocity_model_f[0:27] = V_ds[0, 5]
    dash_velocity_model_f[27:len(sx)] = V_ds[199, 5]
    dash_velocity_model_a[0:54] = V_ds[0, 5]
    dash_velocity_model_a[54:len(sx)] = V_ds[199, 5]

    # 绘制S波速度
    ax7.plot(sx, dash_velocity_model_a, 'k:', label='Model a-ana')
    ax7.plot(sx, dash_velocity_model_f, 'r:', label='Model f-ana')

    fig3.set_size_inches(25/2.54, 35/2.54)
    ax6.tick_params(labelsize=12)
    ax7.tick_params(labelsize=12)

    ax6.legend(['Model a', 'Model b', 'Model c', 'Model d', 'Model e', 'Model f', 'Model a-ana', 'Model f-ana'])
    ax6.set_xlabel('Stress (Pa)', fontsize=12, fontname='Times New Roman')
    ax6.set_ylabel('P-wave Velocity (m/s)', fontsize=12, fontname='Times New Roman')

    ax7.legend(['Model a', 'Model b', 'Model c', 'Model d', 'Model e', 'Model f', 'Model a-ana', 'Model f-ana'])
    ax7.set_xlabel('Stress (Pa)', fontsize=12, fontname='Times New Roman')
    ax7.set_ylabel('S-wave Velocity (m/s)', fontsize=12, fontname='Times New Roman')

    plt.tight_layout()
    plt.show()