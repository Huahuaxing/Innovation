from matplotlib import pyplot as plt
import numpy as np
from scipy.integrate import dblquad
from utils.P3 import P3
import sys

def shelby_tensor_cch(C, a1, a2, a3, p):
    C = C * (1e-9)  # 转化为 MPa
    C_0 = C.copy()

    # 计算 C 的各个分量
    C11 = C[0, 0]
    C12 = C[0, 1]
    C13 = C[0, 2]
    C33 = C[2, 2]
    C44 = C[3, 3]


    # 计算裂缝的 Eshelby 张量
    # 该程序基于 Xu Song 的论文 (Acta Phys. Sin. 2015)
    H = np.zeros((6, 6))
    opt = 1

    for i in range(6):
        for j in range(i, 6):
            if opt in [1, 2, 3, 7, 8, 12, 16, 19, 21]:  # 其他分量为零
                # H[i, j] = dblquad(P3, 0, 2 * np.pi, 0, np.pi, args=(C11, C12, C13, C33, C44, a1, a2, a3, opt))[0]
                H[i, j] = dblquad(lambda ang1, ang2: P3(ang1, ang2, C11, C12, C13, C33, C44, a1, a2, a3, opt),
                                  0, np.pi,
                                  0, 2 * np.pi)[0]
            opt += 1

    # 对称化 H 矩阵
    for i in range(6):
        for j in range(i):
            H[i, j] = H[j, i]

    C66 = (C11 - C12) / 2
    C_matrix = np.array([
        [C11, C12, C13, 0, 0, 0],
        [C12, C11, C13, 0, 0, 0],
        [C13, C13, C33, 0, 0, 0],
        [0, 0, 0, 2 * C44, 0, 0],
        [0, 0, 0, 0, 2 * C44, 0],
        [0, 0, 0, 0, 0, 2 * C66]
    ])

    S = 0.25 * (a1 * a2 * a3) / (4 * np.pi) * H @ C_matrix

    # 计算 Q 矩阵
    E2 = np.eye(6)
    E2[3, 3] = 2
    E2[4, 4] = 2
    E2[5, 5] = 2
    E1 = np.eye(6)

    Q = C_0 @ (E1 - E2 @ S)  # C 扩展为 MPa

    H1 = np.linalg.inv(Q)
    H1 = p * H1

    # 计算 Zn 和 Zt
    Zn = H1[2, 2]
    Zt = H1[4, 4]
    Zn *= 1e-9  # 转换为 Pa
    Zt *= 1e-9  # 转换为 Pa

    return Zn, Zt
