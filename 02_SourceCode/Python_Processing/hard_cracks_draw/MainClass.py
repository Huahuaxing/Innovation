"""
此类以.mat文件作为输入，集成C_eff方法
"""

import numpy as np
import json
from scipy.io import loadmat
from modulus_dry_inclined import modulus_dry_inclined
from modulus_dry_stress import modulus_dry_stress
import os

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

    def __init__(self, dataPath, name=None):
        self.dataPath = dataPath
        self.name = name
        self.init_data()  # 调用加载数据的方法
        self.effective_elastic_matrix()
        print(f'{self.name} 数据加载完成')

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

        self.C_eff = np.zeros((200, 5, 6, 6, 3))  # 这里的第四个维度的6，代表的更多是AR1, AR2，以及AR1+AR2

        for xd in range(3):
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


    def average_velocity(self) -> np.ndarray:
        intermediate_C = np.sum(self.C_eff, axis=1) / 5  # 把五个子模型的等效弹性矩阵取平均
        V_dp = np.zeros((200, 6))
        # V_ds = np.zeros((200, 6))

        # 处理每个模型
        for ak in range(3):
            C_stress = intermediate_C[:, :, :, ak]  # C_eff的维度是(200,5,6,6,6)
            for am in range(200):
                C = C_stress[am, :, :]
                V_dry, CC = modulus_dry_stress(MainClass.c_1, MainClass.sita, C, MainClass.density, self.a1, self.a2, self.a3, self.p, MainClass.B, self.c_density)
                V_dp[am, ak] = V_dry[0, 0]  # am表示压力，ak表示AR1,AR2,AR1+AR2
                # V_ds[am, ak] = V_dry[1, 7]  # 注意Python索引从0开始，所以这里是7而不是8

        return V_dp
    

    def single_stress_velocity(self, n: int) -> np.ndarray:
        '''
        该方法求的是每组第n个子模型的P波速度
        '''
        
        V_dp = np.zeros((200, 3))

        for ak in range(6):
            C_stress = self.C_eff[:, n, :, :, ak]  # C_eff的维度是(200,5,6,6,6) 
            for am in range(200):
                C = C_stress[am, :, :]
                V_dry, CC = modulus_dry_stress(MainClass.c_1, MainClass.sita, C, MainClass.density, self.a1, self.a2, self.a3, self.p, MainClass.B, self.c_density)
                V_dp[am, ak] = V_dry[0, 0]  # am表示压力，ak表示AR1,AR2,AR1+AR2
        
        return V_dp
        
        