import numpy as np

def modulus_dry_inclined(c_density, B, c_1, C, angle, density, sita, V_dry_oblique):
    # V_dry_oblique = np.zeros((3, sita.size))
    # [Z_N, Z_T] = shelby_tensor_cch(C, a1, a2, a3, p)

    Z = np.zeros((6, 6))
    Z_N = 8 * B[3] * c_density / (3 * c_1 * (1 - (C[0, 2] / c_1) ** 2))
    intermediate = B[2] + B[3] - 2 * C[3, 3] * B[3] / (c_1 + C[0, 2] + 2 * C[3, 3])
    Z_T = 16 * c_density / (3 * C[3, 3] * intermediate)

    delta_N = C[2, 2] * Z_N / (1 + C[2, 2] * Z_N)
    delta_T = C[3, 3] * Z_T / (1 + C[3, 3] * Z_T)

    # 这部分是为了获得干燥情况下倾斜裂隙下有效模量
    ssita = np.sin(angle) ** 2
    scsita = np.sin(angle) * np.cos(angle)
    ccsita = np.cos(angle) ** 2

    Z[1, 1] = Z_T * ssita
    Z[2, 2] = Z_N * ccsita
    Z[3, 3] = Z_N * ssita + Z_T * ccsita
    Z[4, 4] = Z_T * ccsita
    Z[5, 5] = Z_T * ssita
    Z[4, 5] = -Z_T * scsita
    Z[5, 4] = Z[4, 5]
    Z[1, 3] = Z[4, 5]
    Z[3, 1] = Z[1, 3]
    Z[2, 3] = -Z_N * scsita
    Z[3, 2] = Z[2, 3]

    # {
    S = np.linalg.inv(C) + Z
    C_eff = np.linalg.inv(S)
    # clear ssita ccsita
    # }

    # 假设 sita 是一个全局变量或作为参数传入
    V_dry_oblique = np.zeros((3, sita.size))  # 需要定义 sita
    for kk in range(sita.size):
        ssita = np.sin(sita[kk]) ** 2
        ccsita = np.cos(sita[kk]) ** 2

        M = (C_eff[1, 1] * ssita + C_eff[3, 3] * ccsita) * (C_eff[3, 3] * ssita + C_eff[2, 2] * ccsita) - ((C_eff[1, 2] + C_eff[3, 3]) ** 2) * ssita * ccsita
        inter_a = C_eff[3, 3] + C_eff[1, 1] * ssita + C_eff[2, 2] * ccsita
        iner_b = np.sqrt(inter_a ** 2 - 4 * M)

        V_p = np.sqrt(inter_a + iner_b) * (1.0 / np.sqrt(2 * density))
        V_sv = np.sqrt(inter_a - iner_b) * (1.0 / np.sqrt(2 * density))
        V_sh = np.sqrt((C_eff[5, 5] * ssita + C_eff[4, 4] * ccsita) / density)

        V_dry_oblique[0, kk] = V_p
        V_dry_oblique[1, kk] = V_sv
        V_dry_oblique[2, kk] = V_sh

    return Z, V_dry_oblique  # Z.shape = (6, 6), V_dry_oblique.shape = (3, sita.size)