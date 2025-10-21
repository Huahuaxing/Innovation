import numpy as np

def modulus_dry_stress(c_1, sita, C, density, a1, a2, a3, p, B, c_density):
    """
    计算干燥状态下的模量和波速
    
    参数:
    c_1: 弹性参数组合
    sita: 角度数组
    C: 弹性矩阵
    density: 密度
    a1, a2, a3: 裂隙几何参数
    p: 裂隙孔隙度
    B: B参数数组
    c_density: 裂隙密度
    
    返回:
    V_dry: 波速数组
    C_eff: 有效弹性矩阵
    """
    V_dry = np.zeros((3, sita.size))
    
    # 计算Z_N和Z_T
    Z_N = 8 * B[4] * c_density / (3 * c_1 * (1 - (C[0, 2] / c_1)**2))
    intermediate = B[3] + B[4] - 2 * C[3, 3] * B[4] / (c_1 + C[0, 2] + 2 * C[3, 3])
    Z_T = 16 * c_density / (3 * C[3, 3] * intermediate)
    
    # 计算delta_N和delta_T
    delta_N = C[2, 2] * Z_N / (1 + C[2, 2] * Z_N)
    delta_T = C[3, 3] * Z_T / (1 + C[3, 3] * Z_T)
    
    # 初始化有效弹性矩阵
    C_eff = np.zeros((6, 6))
    
    # 填充有效弹性矩阵
    C_eff[0, 0] = C[0, 0] * (1 - ((C[0, 2] / c_1)**2) * delta_N)
    C_eff[0, 1] = C[0, 1] * (1 - ((C[0, 2] / (C[0, 1] * C[2, 2]))**2) * delta_N)
    C_eff[1, 0] = C_eff[0, 1]
    C_eff[1, 1] = C_eff[0, 0]
    C_eff[0, 2] = C[0, 2] * (1 - delta_N)
    C_eff[2, 0] = C_eff[0, 2]
    C_eff[1, 2] = C[0, 2] * (1 - delta_N)
    C_eff[2, 1] = C_eff[1, 2]
    C_eff[2, 2] = C[2, 2] * (1 - delta_N)
    C_eff[3, 3] = C[3, 3] * (1 - delta_T)
    C_eff[4, 4] = C[3, 3] * (1 - delta_T)
    C_eff[5, 5] = C[5, 5]
    
    # 计算每个角度的波速
    for kk in range(sita.size):
        ssita = np.sin(sita[kk]) * np.sin(sita[kk])
        ccsita = np.cos(sita[kk]) * np.cos(sita[kk])
        
        M = (C_eff[1, 1] * ssita + C_eff[3, 3] * ccsita) * (C_eff[3, 3] * ssita + C_eff[2, 2] * ccsita) - \
            ((C_eff[1, 2] + C_eff[3, 3])**2) * ssita * ccsita
        inter_a = C_eff[3, 3] + C_eff[1, 1] * ssita + C_eff[2, 2] * ccsita
        iner_b = np.sqrt(inter_a**2 - 4 * M)
        
        V_p = np.sqrt(inter_a + iner_b) * (1.0 / np.sqrt(2 * density))
        V_sv = np.sqrt(inter_a - iner_b) * (1.0 / np.sqrt(2 * density))
        V_sh = np.sqrt((C_eff[5, 5] * ssita + C_eff[4, 4] * ccsita) / density)
        
        V_dry[0, kk] = V_p  # P波
        V_dry[1, kk] = V_sv  # SV波
        V_dry[2, kk] = V_sh  # SH波
    
    return V_dry, C_eff
