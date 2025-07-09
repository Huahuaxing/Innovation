import numpy as np
import json
from scipy.io import loadmat
from utils.modulus_dry_inclined import modulus_dry_inclined
from utils.modulus_dry_stress import modulus_dry_stress
import os
import sys

class MainClass:
    sita = np.linspace(0, np.pi, 31)  # sita.shape = (31,)
    angle = 0
    # TI背景介质下
    
    C = np.zeros((6, 6))            # 弹性矩阵
    C_iso = np.zeros((2, 2))        # 各向同性介质下的弹性矩阵 

    backProperty = 2                # 1表示anisotropic,2表示isotropic
    
    K = 4.829e9
    MU = 3.180e9

    density = 2.504e3
    V_dry = np.zeros((3, sita.size))  # V_dry.shape = (3, 31) [0]P,[1]SV,[2]SH  
    V_saturated = np.zeros((3, sita.size))
    
    V_dry_oblique = np.zeros((3, sita.size))
    V_saturated_oblique = np.zeros((3, sita.size))

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

    c_1 = np.sqrt(C[0, 0] * C[2, 2])  # 注意 Python 的索引从 0 开始

    B = np.zeros(6)  # 初始化 B 数组
    B[2] = np.sqrt(C[5, 5] / C[3, 3])
    B[3] = np.sqrt((c_1 - C[0, 2]) * (c_1 + C[0, 2] + 2 * C[3, 3]) / (C[2, 2] * C[3, 3]))
    B[4] = np.sqrt((c_1 + C[0, 2]) * (c_1 - C[0, 2] - 2 * C[3, 3]) / (C[2, 2] * C[3, 3]))
    B[0] = 0.5 * (B[3] + B[4])
    B[1] = 0.5 * (B[3] - B[4])

    c_filling = 2.25e9

    def __init__(self, dataPath):
        self.dataPath = dataPath
        self.init_data()  # 调用加载数据的方法
        self.effective_elastic_matrix()
        print(f'{dataPath} 数据加载完成')


    # 加载三个数据 （aperture_record, radius_record, sx）
    def init_data(self):
        # 根据文件扩展名判断是mat文件还是json文件
        file_extension = os.path.splitext(self.dataPath)[1].lower()
        if file_extension == '.mat':
            # 加载mat文件
            data = loadmat(self.dataPath)
            # mat文件加载后的数据结构不一样，可能需要调整
            self.aperture_record = data['aperture_record']      # aperture_record.shape = (5, 20, 200, 6)
            self.radius_record = data['radius_record']          # radius_record.shape = (5, 20, 200, 6)
            self.sx = data['sx'].flatten()  # mat文件加载后通常需要平展数组
        elif file_extension == '.json':
            # 加载json文件
            with open(self.dataPath, 'r', encoding='utf-8') as f:
                data = json.load(f)
            self.aperture_record = np.array(data['aperture_record'])
            self.radius_record = np.array(data['radius_record'])
            self.sx = np.array(data['sx'])
        else:
            raise ValueError(f"不支持的文件格式: {file_extension}，只支持.mat和.json文件")


    def effective_elastic_matrix(self):
        # c_density = 0.05
        # c_as = 0.01  # for 59-1490

        dimention = 3                   # 2表示2D，3表示3D
        n = 1                           # 裂隙的个数

        self.C_eff = np.zeros((200, 5, 6, 6, 6))  # 这里的第四个维度的6，代表的更多是AR1, AR2，以及AR1+AR2

        for xd in range(6):
            for xa in range(200):
                for xc in range(5):
                    Z_intermediate = np.zeros((6, 6))
                    for xb in range(20):

                        self.a1 = 4.64e-1
                        self.a2 = self.radius_record[xc, xb, xa, xd]  # 这个代表的是长轴的，表示的半轴的长度，单位是m
                        self.a3 = self.aperture_record[xc, xb, xa, xd] * 2 / np.pi  # 纵横比
                        self.c_as = self.a3 / self.a2

                        S_mian = 20 * 20 * 10**(-4)  # 这个表示的是单元体的面积
                        if dimention == 2:
                            self.c_density = n * (self.a2**2) / S_mian
                            self.p = self.n * np.pi * self.a2 * self.a3 / S_mian  # 这个是柱体条件下的（2D）crack porosity(孔隙率)   
                        elif dimention == 3:
                            self.c_density = n * (self.a2**3) / S_mian
                            self.p = 4 * np.pi * self.c_density * self.c_as / 3.0  # 这个是椭圆条件下的（3D）crack porosity

                        Z, V_dry_oblique = modulus_dry_inclined(self.c_density, MainClass.B, MainClass.c_1, MainClass.C, MainClass.angle, MainClass.density, MainClass.sita, MainClass.V_dry_oblique)
                        Z_intermediate = Z + Z_intermediate         # Z.shape = (6, 6), Z_intermediate.shape = (6, 6)

                    S = np.linalg.inv(MainClass.C) + Z_intermediate
                    self.C_eff[xa, xc, :, :, xd] = np.linalg.inv(S)


    # 计算角度-波速数据
    def calculate_angle_velocity(self):
        V_dry = np.zeros((200, 3, 31))
        intermediate_C = np.sum(self.C_eff, axis=1) / 5  # 存储五个子模型的平均弹性矩阵
        # 处理每个模型
        for ak in range(6):
            C_stress = intermediate_C[:, :, :, ak]  # C_eff的维度是(200,5,6,6,6)
            for am in range(200):
                C = C_stress[am, :, :]
                V_dry_temp, CC = modulus_dry_stress(MainClass.c_1, MainClass.sita, C, MainClass.density, self.a1, self.a2, self.a3, self.p, MainClass.B, self.c_density)
                V_dry[am, :, :] = V_dry_temp
        return V_dry                                    # V_dry.shape = (200, 3, 31) [0]P,[1]SV,[2]SH  


    # 五个子模型平均波度，角度为90
    def average_velocity(self) -> np.ndarray:
        intermediate_C = np.sum(self.C_eff, axis=1) / 5
        V_average = np.zeros((3, 200, 6))

        # 处理每个模型
        for ak in range(6):
            C_stress = intermediate_C[:, :, :, ak]  # C_eff的维度是(200,5,6,6,6)
            for am in range(200):
                C = C_stress[am, :, :]
                V_dry, CC = modulus_dry_stress(MainClass.c_1, MainClass.sita, C, MainClass.density, self.a1, self.a2, self.a3, self.p, MainClass.B, self.c_density)
                V_average[:, am, ak] = V_dry[:, 16]    # 入射角90度

        return V_average                                # V_average.shape = (3, 200, 6)
    

    def single_stress_velocity(self, n: int) -> np.ndarray:
        '''
        该方法求的是每组第n个子模型的P波速度
        '''
        
        V_dp = np.zeros((200, 6))

        for ak in range(6):
            C_stress = self.C_eff[:, n, :, :, ak]  # C_eff的维度是(200,5,6,6,6) 
            for am in range(200):
                C = C_stress[am, :, :]
                V_dry, CC = modulus_dry_stress(MainClass.c_1, MainClass.sita, C, MainClass.density, self.a1, self.a2, self.a3, self.p, MainClass.B, self.c_density)
                V_dp[am, ak] = V_dry[0, 0]  # am表示压力，ak表示AR1,AR2,AR1+AR2
        
        return V_dp

    
    # def extract_E_nu_from_C(C):
    #     """
    #     从一个 6x6 各向同性刚度矩阵中提取杨氏模量 E 和泊松比 ν
    #     C: shape (..., 6, 6)
    #     返回：E, ν
    #     """
    #     C11 = C[:, 0, 0]
    #     C12 = C[..., 0, 1]

    #     # 防止除零
    #     denom = C11 + C12
    #     denom[denom == 0] = 1e-12

    #     E = (C11 - C12) * (C11 + 2 * C12) / denom
    #     nu = C12 / denom
    #     return E, nu


    # # 假设你的数组叫 stiffness_array，形状 (200, 5, 6, 6, 6)
    # # 遍历最后一维的6个刚度矩阵，并提取E和ν
    # def compute_E_nu_batch(self):
    #     """
    #     处理整个数组：shape = (200, 5, 6, 6, 6)
    #     返回：
    #         E_vals: shape (200, 6)
    #         nu_vals: shape (200, 6)
    #     """
    #     E_vals = np.zeros((200, 6))
    #     nu_vals = np.zeros((200, 6))

    #     for i in range(6):
    #         C = np.mean(self.C_eff, axis=1)[..., i]
    #         E, nu = self.extract_E_nu_from_C(C)
    #         E_vals[..., i] = E
    #         nu_vals[..., i] = nu

    #     return E_vals, nu_vals



if __name__ == '__main__':

    # 将波速数据以csv单独存储起来，方便后续的绘图
    model1Path = '.\\05_ProcessedData\\record\\ellipse_data_aligned_radius_aperture_record.json'
    model2Path = '.\\05_ProcessedData\\record\\polygonal_data_radius_aperture_record.json'

    model1 = MainClass(dataPath=model1Path)
    model2 = MainClass(dataPath=model2Path)

    # V_average = model1.average_velocity()
    # V_average_2 = model2.average_velocity()

    # for i in range(6):
    #     np.savetxt('.\\05_ProcessedData\\velocity\\V_ellipse_'+str(i+1)+'.csv', V_average[:, :, i], delimiter=',')
    #     np.savetxt('.\\05_ProcessedData\\velocity\\V_polygonal_'+str(i+1)+'.csv', V_average_2[:, :, i], delimiter=',')


    # # 通过有效弹性矩阵计算出E和nu
    # E1, nu1 = model1.compute_E_nu_batch()
    # E2, nu2 = model2.compute_E_nu_batch()
    # np.savetxt('.\\05_ProcessedData\\E_nu\\E_ellipse.csv', E1, delimiter=',')
    # np.savetxt('.\\05_ProcessedData\\E_nu\\E_polygonal.csv', E2, delimiter=',')
    # np.savetxt('.\\05_ProcessedData\\E_nu\\nu_ellipse.csv', nu1, delimiter=',')
    # np.savetxt('.\\05_ProcessedData\\E_nu\\nu_polygonal.csv', nu2, delimiter=',')


    # 存储有效弹性矩阵C_eff
    np.save('.\\05_ProcessedData\\C_eff\\C_eff_ellipse.npy', model1.C_eff)
    np.save('.\\05_ProcessedData\\C_eff\\C_eff_polygonal.npy', model2.C_eff)


