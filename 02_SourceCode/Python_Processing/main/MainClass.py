import numpy as np
import json
from scipy.io import loadmat
from scipy.io import savemat
import os
import sys
import matplotlib.pyplot as plt

plt.rcParams['font.sans-serif'] = ['SimHei']  # 使用黑体
plt.rcParams['axes.unicode_minus'] = False    # 正确显示负号

sys.path.append((os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))

from utils.modulus_dry_inclined import modulus_dry_inclined
from utils.modulus_dry_stress import modulus_dry_stress

class MainClass:
    sita = np.linspace(0, np.pi, 31) # 波速角度数组，从0到π，31个点 (弧度)
    angle = 0                        # 裂隙倾斜角度 (弧度)
    # TI背景介质下
    
    C = np.zeros((6, 6))            # 弹性矩阵/刚度矩阵 (Pa)
    C_iso = np.zeros((2, 2))        # 各向同性介质下的弹性矩阵 (Pa)

    backProperty = 2                # 去除裂隙的背景介质属性: 1表示各向异性(anisotropic), 2表示各向同性(isotropic)
    
    K = 4.829e9                     # 体积模量 (Pa)
    MU = 3.180e9                    # 剪切模量 (Pa)

    density = 2020               # 密度 (kg/m³)
    V_dry = np.zeros((3, sita.size))  # 干燥条件下的波速数组 (m/s), [0]P波,[1]SV波,[2]SH波
    V_saturated = np.zeros((3, sita.size))  # 饱和条件下的波速数组 (m/s)
    
    V_dry_oblique = np.zeros((3, sita.size))  # 倾斜裂隙条件下干燥介质的波速数组 (m/s)
    V_saturated_oblique = np.zeros((3, sita.size))  # 倾斜裂隙条件下饱和介质的波速数组 (m/s)

    if backProperty == 1:
        # 各向异性介质的弹性常数设置 (Pa)
        C[0, 0] = 47.31e9           # C11 弹性常数 (Pa)
        C[2, 2] = 33.89e9           # C33 弹性常数 (Pa)
        C[0, 1] = 7.83e9            # C12 弹性常数 (Pa)
        C[0, 2] = 5.29e9            # C13 弹性常数 (Pa)
        C[3, 3] = 17.15e9           # C44 弹性常数 (Pa)
        C[1, 1] = C[0, 0]           # C22 = C11 (横向各向同性)
        C[1, 2] = C[0, 2]           # C23 = C13 (横向各向同性)
        C[5, 5] = 0.5 * (C[0, 0] - C[0, 1])  # C66 = (C11-C12)/2 (横向各向同性)
        C[4, 4] = C[3, 3]           # C55 = C44 (横向各向同性)
        C[1, 0] = C[0, 1]           # C21 = C12 (对称性)
        C[2, 0] = C[0, 2]           # C31 = C13 (对称性)
        C[2, 1] = C[1, 2]           # C32 = C23 (对称性)
    elif backProperty == 2:
        # 各向同性介质的弹性常数计算 (Pa)
        C_iso[0, 0] = K + 4 * MU / 3.0  # λ + 2μ (Pa)
        C_iso[0, 1] = K - 2 * MU / 3.0  # λ (Pa)
        # C_iso[0, 0] = 6.292e9
        # C_iso[0, 1] = 3.692e9  # for zizhen
        
        # 填充完整的弹性矩阵 (各向同性)
        C[0, 0] = C_iso[0, 0]       # C11 (Pa)
        C[0, 1] = C_iso[0, 1]       # C12 (Pa)
        C[0, 2] = C[0, 1]           # C13 = C12 (Pa)
        C[1, 0] = C[0, 2]           # C21 = C13 (Pa)
        C[1, 1] = C[0, 0]           # C22 = C11 (Pa)
        C[1, 2] = C[1, 0]           # C23 = C21 (Pa)
        C[2, 0] = C[0, 2]           # C31 = C13 (Pa)
        C[2, 1] = C[1, 0]           # C32 = C21 (Pa)
        C[2, 2] = C[1, 1]           # C33 = C22 (Pa)
        C[5, 5] = 0.5 * (C[0, 0] - C[0, 1])  # C66 = (C11-C12)/2 = μ (Pa)
        C[4, 4] = C[5, 5]           # C55 = C66 (Pa)
        C[3, 3] = C[5, 5]           # C44 = C66 (Pa)

    c_1 = np.sqrt(C[0, 0] * C[2, 2])  # 特征参数 c_1 (Pa)

    B = np.zeros(5)                 # 初始化 B 数组 (无量纲参数)
    B[2] = np.sqrt(C[5, 5] / C[3, 3])  # B[2] = sqrt(C66/C44)
    B[3] = np.sqrt((c_1 - C[0, 2]) * (c_1 + C[0, 2] + 2 * C[3, 3]) / (C[2, 2] * C[3, 3]))  # 各向异性参数
    B[4] = np.sqrt((c_1 + C[0, 2]) * (c_1 - C[0, 2] - 2 * C[3, 3]) / (C[2, 2] * C[3, 3]))  # 各向异性参数
    B[0] = 0.5 * (B[3] + B[4])      # B[0] = (B[3] + B[4])/2
    B[1] = 0.5 * (B[3] - B[4])      # B[1] = (B[3] - B[4])/2

    c_filling = 2.25e9              # 填充材料的弹性参数 (Pa)

    def __init__(self, dataPath):
        self.dataPath = dataPath
        self.init_data()  # 调用加载数据的方法
        self.effective_elastic_matrix()
        print(f'{dataPath} 数据加载完成')


    # 加载三个数据 （aperture_record, radius_record, sx）
    def init_data(self):
        """
        根据文件类型加载裂隙数据
        """
        # 根据文件扩展名判断是mat文件还是json文件
        file_extension = os.path.splitext(self.dataPath)[1].lower()
        if file_extension == '.mat':
            # 加载mat文件
            data = loadmat(self.dataPath)
            # mat文件加载后的数据结构不一样，可能需要调整
            self.aperture_record = data['aperture_record']      # 裂隙开度记录 (m), shape = (5, 20, 200, 6)
            self.radius_record = data['radius_record']          # 裂隙半径记录 (m), shape = (5, 20, 200, 6)
            self.P = data['sx'].flatten()                       # 应力数组 (Pa), mat文件加载后通常需要平展数组
            print('路径正确')
        elif file_extension == '.json':
            # 加载json文件
            with open(self.dataPath, 'r', encoding='utf-8') as f:
                data = json.load(f)
            self.aperture_record = np.array(data['aperture_record'])  # 裂隙开度记录 (m)
            self.radius_record = np.array(data['radius_record'])      # 裂隙半径记录 (m)
            self.P = np.array(data['sx'])                            # 应力数组 (Pa)
            print('路径正确')
        else:
            raise ValueError(f"不支持的文件格式: {file_extension}，只支持.mat和.json文件")


    def effective_elastic_matrix(self):
        """
        计算含裂隙介质的有效弹性矩阵
        """
        # c_density = 0.05
        # c_as = 0.01  # for 59-1490

        dimention = 3                   # 维度: 2表示2D，3表示3D
        n = 20                          # 裂隙的个数

        self.C_eff = np.zeros((200, 5, 6, 6, 6))  # 有效弹性矩阵 (Pa), 第五个维度的6代表不同的纵横比(AR)组合

        for xd in range(6):
            for xa in range(200):
                for xc in range(5):
                    Z_intermediate = np.zeros((6, 6))  # 中间计算矩阵 (Pa^-1)
                    for xb in range(20):

                        self.a1 = 4.64e-1                                  # 参考长度 (m)
                        self.a2 = self.radius_record[xc, xb, xa, xd]       # 裂隙长轴半长 (m)
                        self.a3 = self.aperture_record[xc, xb, xa, xd] * 2 / np.pi  # 裂隙短轴半长 (m)
                        self.c_as = self.a3 / self.a2                      # 裂隙纵横比 (无量纲)

                        S_mian = 20 * 20 * 10**(-4)  # 代表单元体的体积 (m²)
                        if   dimention == 2:
                            self.c_density = n * (self.a2**2) / S_mian     # 2D裂隙密度 (无量纲)
                            self.p = n * np.pi * self.a2 * self.a3 / S_mian  # 2D裂隙孔隙率 (无量纲)
                        elif dimention == 3:
                            self.c_density = n * (self.a2**3) / S_mian     # 3D裂隙密度 (无量纲)
                            self.p = 4 * np.pi * self.c_density * self.c_as / 3.0  # 3D裂隙孔隙率 (无量纲)

                        Z, V_dry_oblique = modulus_dry_inclined(self.c_density, MainClass.B, MainClass.c_1, MainClass.C, MainClass.angle, MainClass.density, MainClass.sita)
                        Z_intermediate = Z + Z_intermediate         # 累加柔度贡献 (Pa^-1)

                    S = np.linalg.inv(MainClass.C) + Z_intermediate  # 总柔度矩阵 (Pa^-1)
                    self.C_eff[xa, xc, :, :, xd] = np.linalg.inv(S)  # 有效弹性矩阵 (Pa)


    # 计算角度-波速数据 (先平均C_eff，再计算波速)
    def angle_velocity(self):
        """
        原始方法：先平均弹性矩阵，再计算波速
        """
        V_dry = np.zeros((200, 3, 31, 6))
        intermediate_C = np.sum(self.C_eff, axis=1) / 5  # 存储五个子模型的平均弹性矩阵
        # 处理每个模型
        for ak in range(6):
            C_stress = intermediate_C[:, :, :, ak]  # C_eff的维度是(200,5,6,6,6)
            for am in range(200):
                C = C_stress[am, :, :]
                V_dry_temp, CC = modulus_dry_stress(MainClass.c_1, MainClass.sita, C, MainClass.density, self.a1, self.a2, self.a3, self.p, MainClass.B, self.c_density)
                V_dry[am, :, :, ak] = V_dry_temp
        return V_dry                                    # V_dry.shape = (200, 3, 31, 6) [0]P,[1]SV,[2]SH

    
    def average_velocity_new(self, degree: int) -> np.ndarray:
        """
        计算给定角度的平均波速
        """
        radian = [np.deg2rad(degree)]
        radian = np.array(radian)
        intermediate_C = np.sum(self.C_eff, axis=1) / 5
        V_average = np.zeros((3, 200, 6))

        # 处理每个模型
        for ak in range(6):
            C_stress = intermediate_C[:, :, :, ak]  # C_eff的维度是(200,5,6,6,6)
            for am in range(200):
                C = C_stress[am, :, :]
                V_dry, CC = modulus_dry_stress(MainClass.c_1, radian, C, MainClass.density, self.a1, self.a2, self.a3, self.p, MainClass.B, self.c_density)
                V_average[:, am, ak] = V_dry[:, 0]    # 入射角degree度
        return V_average 



    # 每组平均波速 (先平均C_eff，再计算特定角度的波速)
    def average_velocity(self, degreeIndex: int) -> np.ndarray:
        '''
        原始方法：先平均弹性矩阵，再计算特定角度的波速
        
        参数:
        degree: 入射角，0-30索引，0表示0度，15表示90度，30表示180度
        
        返回:
        V_average: 平均波速数组，shape = (3, 200, 6)
        '''
        intermediate_C = np.sum(self.C_eff, axis=1) / 5
        V_average = np.zeros((3, 200, 6))

        # 处理每个模型
        for ak in range(6):
            C_stress = intermediate_C[:, :, :, ak]  # C_eff的维度是(200,5,6,6,6)
            for am in range(200):
                C = C_stress[am, :, :]
                V_dry, CC = modulus_dry_stress(MainClass.c_1, MainClass.sita, C, MainClass.density, self.a1, self.a2, self.a3, self.p, MainClass.B, self.c_density)
                V_average[:, am, ak] = V_dry[:, degree]    # 入射角degree度

        return V_average                                # V_average.shape = (3, 200, 6)

        
    def all_models_velocity(self, degree: int) -> np.ndarray:
        '''
        返回所有子模型在特定角度的波速，不进行平均
        
        参数:
        degree: 入射角，0-30索引，0表示0度，15表示90度，30表示180度
        
        返回:
        V_all: 所有子模型的波速数组，shape = (5, 3, 200, 6)
               5个子模型, 3种波, 200个压力点, 6种纵横比
        '''
        V_all = np.zeros((5, 3, 200, 6))  # 存储所有子模型的波速
        
        for xc in range(5):  # 遍历5个子模型
            for ak in range(6):  # 遍历6种纵横比组合
                for am in range(200):  # 遍历200个压力点
                    C = self.C_eff[am, xc, :, :, ak]  # 获取当前子模型的弹性矩阵
                    V_dry, _ = modulus_dry_stress(MainClass.c_1, MainClass.sita, C, MainClass.density, 
                                                self.a1, self.a2, self.a3, self.p, MainClass.B, self.c_density)
                    V_all[xc, :, am, ak] = V_dry[:, degree]  # (5,3,200,6)
        
        return V_all


    def CC(self):
        intermediate_C = np.sum(self.C_eff, axis=1) / 5
        CC_all = np.zeros((200, 6, 6, 6))
        for ak in range(6):
            C_stress = intermediate_C[:, :, :, ak]  # C_eff的维度是(200,5,6,6,6)
            for am in range(200):
                C = C_stress[am, :, :]
                _, CC = modulus_dry_stress(MainClass.c_1, MainClass.sita, C, MainClass.density, self.a1, self.a2, self.a3, self.p, MainClass.B, self.c_density)
                CC_all[am, :, :, ak] = CC
        return CC_all                                # CC_all.shape = (200, 6, 6, 6)

if __name__ == '__main__':

    model1Path = '.\\05_ProcessedData\\record\\ellipse_data_aligned_radius_aperture_record.json'
    model2Path = '.\\05_ProcessedData\\record\\polygonal_data_radius_aperture_record.json'

    model1 = MainClass(dataPath=model1Path)
    model2 = MainClass(dataPath=model2Path)

    

    # savemat(f'E:\\OneDrive\\Project\\Innovation\\05_ProcessedData\\C_eff\\C_eff_ellipse.mat', {'C_eff': model1.C_eff})
    # savemat(f'E:\\OneDrive\\Project\\Innovation\\05_ProcessedData\\C_eff\\C_eff_polygonal.mat', {'C_eff': model2.C_eff})

    # CC_ellipse = model1.CC()
    # CC_polygonal = model2.CC()
    # savemat(f'E:\\OneDrive\\Project\\Innovation\\05_ProcessedData\\C_eff\\CC_ellipse.mat', {'CC': CC_ellipse})
    # savemat(f'E:\\OneDrive\\Project\\Innovation\\05_ProcessedData\\C_eff\\CC_polygonal.mat', {'CC': CC_polygonal})

    # 绘制波速图,进行多边形和椭圆裂隙的平均速度对比
    def plot_average_velocity(model1, model2, degree: int):

        v_ellipse = model1.average_velocity(degree)    # shape = (3, 200, 6)
        v_polygonal = model2.average_velocity(degree)

        indices = [0, 4, 3, 2, 1, 5];
        titles = ['20AR1', '16AR1+4AR2', '12AR1+8AR2', '8AR1+12AR2', '4AR1+16AR2', '20AR2']

        fig1, axes1 = plt.subplots(2, 3, figsize=(12, 8))
        fig1.suptitle('vp速度对比图', fontsize=16)
        for i in range(2):
            for j in range(3):
                index = i * 3 + j
                axes1[i, j].plot(model1.P, v_ellipse[0, :, indices[index]], 'b-', label='ellipse')
                axes1[i, j].plot(model2.P, v_polygonal[0, :, indices[index]], 'r-', label='polygonal')
                axes1[i, j].legend(fontsize=12)
                axes1[i, j].set_title(f'{titles[index]}', fontsize=14)
                axes1[i, j].set_xlabel('压力 (MPa)', fontsize=12)
                axes1[i, j].set_ylabel('vp (m/s)', fontsize=12)
                axes1[i, j].grid(True)
        plt.tight_layout()

        fig2, axes2 = plt.subplots(2, 3, figsize=(12, 8))
        fig2.suptitle('vsv速度对比图', fontsize=16)
        for i in range(2):
            for j in range(3):
                index = i * 3 + j
                axes2[i, j].plot(model1.P, v_ellipse[1, :, indices[index]], 'b-', label='ellipse')
                axes2[i, j].plot(model2.P, v_polygonal[1, :, indices[index]], 'r-', label='polygonal')
                axes2[i, j].legend(fontsize=12)
                axes2[i, j].set_title(f'{titles[index]}', fontsize=14)
                axes2[i, j].set_xlabel('压力 (MPa)', fontsize=12)
                axes2[i, j].set_ylabel('vsv (m/s)', fontsize=12)
                axes2[i, j].grid(True)
        plt.tight_layout()

        fig3, axes3 = plt.subplots(2, 3, figsize=(12, 8))
        fig3.suptitle('vsh速度对比图', fontsize=16)
        for i in range(2):
            for j in range(3):
                index = i * 3 + j
                axes3[i, j].plot(model1.P, v_ellipse[2, :, indices[index]], 'b-', label='ellipse')
                axes3[i, j].plot(model2.P, v_polygonal[2, :, indices[index]], 'r-', label='polygonal')
                axes3[i, j].legend(fontsize=12)
                axes3[i, j].set_title(f'{titles[index]}', fontsize=14)
                axes3[i, j].set_xlabel('压力 (MPa)', fontsize=12)
                axes3[i, j].set_ylabel('vsh (m/s)', fontsize=12)
                axes3[i, j].grid(True)
        plt.tight_layout()
        plt.show()

        np.savetxt(f'E:\\OneDrive\\Project\\Innovation\\05_ProcessedData\\velocity\\isotropic_matrix\\n_20\\degree_180\\vp_ellipse.csv', vp_ellipse[0, :, :], delimiter=',')
        np.savetxt(f'E:\\OneDrive\\Project\\Innovation\\05_ProcessedData\\velocity\\isotropic_matrix\\n_20\\degree_180\\vp_polygonal.csv', vp_polygonal[0, :, :], delimiter=',')
        np.savetxt(f'E:\\OneDrive\\Project\\Innovation\\05_ProcessedData\\velocity\\isotropic_matrix\\n_20\\degree_180\\vsv_ellipse.csv', vsv_ellipse[1, :, :], delimiter=',')
        np.savetxt(f'E:\\OneDrive\\Project\\Innovation\\05_ProcessedData\\velocity\\isotropic_matrix\\n_20\\degree_180\\vsv_polygonal.csv', vsv_polygonal[1, :, :], delimiter=',')
        np.savetxt(f'E:\\OneDrive\\Project\\Innovation\\05_ProcessedData\\velocity\\isotropic_matrix\\n_20\\degree_180\\vsh_ellipse.csv', vsh_ellipse[2, :, :], delimiter=',')
        np.savetxt(f'E:\\OneDrive\\Project\\Innovation\\05_ProcessedData\\velocity\\isotropic_matrix\\n_20\\degree_180\\vsh_polygonal.csv', vsh_polygonal[2, :, :], delimiter=',')
        print(f'已保存到 E:\\OneDrive\\Project\\Innovation\\05_ProcessedData\\velocity\\isotropic_matrix\\n_20\\degree_180')


    def plot_angle_velocity(model1, model2):

        vp_ellipse = model1.angle_velocity()
        vp_polygonal = model2.angle_velocity()
        vsv_ellipse = model1.angle_velocity()
        vsv_polygonal = model2.angle_velocity()
        vsh_ellipse = model1.angle_velocity()
        vsh_polygonal = model2.angle_velocity()

        fig1, axes1 = plt.subplots(2, 3, figsize=(12, 8))
        fig1.suptitle('vp速度对比图', fontsize=16)
        for i in range(2):
            for j in range(3):
                index = i * 3 + j
                axes1[i, j].plot(model1.sita, vp_ellipse[100, 0, :, index], 'b-', label='ellipse')
                axes1[i, j].plot(model2.sita, vp_polygonal[100, 0, :, index], 'r-', label='polygonal')
                axes1[i, j].legend(fontsize=12)
                axes1[i, j].set_title(f'{i}P, {j}S', fontsize=14)
                axes1[i, j].set_xlabel('压力 (MPa)', fontsize=12)
                axes1[i, j].set_ylabel('vp (m/s)', fontsize=12)
                axes1[i, j].grid(True)
        plt.tight_layout()

        fig2, axes2 = plt.subplots(2, 3, figsize=(12, 8))
        fig2.suptitle('vsv速度对比图', fontsize=16)
        for i in range(2):
            for j in range(3):
                index = i * 3 + j
                axes2[i, j].plot(model1.sita, vsv_ellipse[100, 1, :, index], 'b-', label='ellipse')
                axes2[i, j].plot(model2.sita, vsv_polygonal[100, 1, :, index], 'r-', label='polygonal')
                axes2[i, j].legend(fontsize=12)
                axes2[i, j].set_title(f'{i}P, {j}S', fontsize=14)
                axes2[i, j].set_xlabel('压力 (MPa)', fontsize=12)
                axes2[i, j].set_ylabel('vsv (m/s)', fontsize=12)
                axes2[i, j].grid(True)
        plt.tight_layout()

        fig3, axes3 = plt.subplots(2, 3, figsize=(12, 8))
        fig3.suptitle('vsh速度对比图', fontsize=16)
        for i in range(2):
            for j in range(3):
                index = i * 3 + j
                axes3[i, j].plot(model1.sita, vsh_ellipse[100, 2, :, index], 'b-', label='ellipse')
                axes3[i, j].plot(model2.sita, vsh_polygonal[100, 2, :, index], 'r-', label='polygonal')
                axes3[i, j].legend(fontsize=12)
                axes3[i, j].set_title(f'{i}P, {j}S', fontsize=14)
                axes3[i, j].set_xlabel('压力 (MPa)', fontsize=12)
                axes3[i, j].set_ylabel('vsh (m/s)', fontsize=12)
                axes3[i, j].grid(True)
        plt.tight_layout()
        plt.show()
    

    def plot_average_velocity_new(model1, model2, degree: int):
        v_ellipse = model1.average_velocity_new(degree)
        v_polygonal = model2.average_velocity_new(degree)

        indices = [0, 4, 3, 2, 1, 5];
        titles = ['20AR1', '16AR1+4AR2', '12AR1+8AR2', '8AR1+12AR2', '4AR1+16AR2', '20AR2']

        fig1, axes1 = plt.subplots(2, 3, figsize=(12, 8))
        fig1.suptitle('vp速度对比图', fontsize=16)
        for i in range(2):
            for j in range(3):
                index = i * 3 + j
                axes1[i, j].plot(model1.P, v_ellipse[0, :, indices[index]], 'b-', label='ellipse')
                axes1[i, j].plot(model2.P, v_polygonal[0, :, indices[index]], 'r-', label='polygonal')
                axes1[i, j].legend(fontsize=12)
                axes1[i, j].set_title(f'{titles[index]}', fontsize=14)
                axes1[i, j].set_xlabel('压力 (MPa)', fontsize=12)
                axes1[i, j].set_ylabel('vp (m/s)', fontsize=12)
                axes1[i, j].grid(True)
        plt.tight_layout()

        fig2, axes2 = plt.subplots(2, 3, figsize=(12, 8))
        fig2.suptitle('vsv速度对比图', fontsize=16)
        for i in range(2):
            for j in range(3):
                index = i * 3 + j
                axes2[i, j].plot(model1.P, v_ellipse[1, :, indices[index]], 'b-', label='ellipse')
                axes2[i, j].plot(model2.P, v_polygonal[1, :, indices[index]], 'r-', label='polygonal')
                axes2[i, j].legend(fontsize=12)
                axes2[i, j].set_title(f'{titles[index]}', fontsize=14)
                axes2[i, j].set_xlabel('压力 (MPa)', fontsize=12)
                axes2[i, j].set_ylabel('vsv (m/s)', fontsize=12)
                axes2[i, j].grid(True)
        plt.tight_layout()

        fig3, axes3 = plt.subplots(2, 3, figsize=(12, 8))
        fig3.suptitle('vsh速度对比图', fontsize=16)
        for i in range(2):
            for j in range(3):
                index = i * 3 + j
                axes3[i, j].plot(model1.P, v_ellipse[2, :, indices[index]], 'b-', label='ellipse')
                axes3[i, j].plot(model2.P, v_polygonal[2, :, indices[index]], 'r-', label='polygonal')
                axes3[i, j].legend(fontsize=12)
                axes3[i, j].set_title(f'{titles[index]}', fontsize=14)
                axes3[i, j].set_xlabel('压力 (MPa)', fontsize=12)
                axes3[i, j].set_ylabel('vsh (m/s)', fontsize=12)
                axes3[i, j].grid(True)
        plt.tight_layout()
        plt.show()

        np.savetxt(f'E:\\OneDrive\\Project\\Innovation\\05_ProcessedData\\velocity\\isotropic_matrix\\n_20\\degree_45\\vp_ellipse.csv', v_ellipse[0, :, :], delimiter=',')
        np.savetxt(f'E:\\OneDrive\\Project\\Innovation\\05_ProcessedData\\velocity\\isotropic_matrix\\n_20\\degree_45\\vp_polygonal.csv', v_polygonal[0, :, :], delimiter=',')
        np.savetxt(f'E:\\OneDrive\\Project\\Innovation\\05_ProcessedData\\velocity\\isotropic_matrix\\n_20\\degree_45\\vsv_ellipse.csv', v_ellipse[1, :, :], delimiter=',')
        np.savetxt(f'E:\\OneDrive\\Project\\Innovation\\05_ProcessedData\\velocity\\isotropic_matrix\\n_20\\degree_45\\vsv_polygonal.csv', v_polygonal[1, :, :], delimiter=',')
        np.savetxt(f'E:\\OneDrive\\Project\\Innovation\\05_ProcessedData\\velocity\\isotropic_matrix\\n_20\\degree_45\\vsh_ellipse.csv', v_ellipse[2, :, :], delimiter=',')
        np.savetxt(f'E:\\OneDrive\\Project\\Innovation\\05_ProcessedData\\velocity\\isotropic_matrix\\n_20\\degree_45\\vsh_polygonal.csv', v_polygonal[2, :, :], delimiter=',')
        print(f'已保存到 E:\\OneDrive\\Project\\Innovation\\05_ProcessedData\\velocity\\isotropic_matrix\\n_20\\degree_45')
        
    # plot_average_velocity(model1, model2, 0)
    plot_average_velocity_new(model1, model2, 45)


