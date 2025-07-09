import numpy as np
from shelby_tensor_cch import shelby_tensor_cch

def modulus_dry(c_1, sita, C, density, a1, a2, a3, p):
    V_dry = np.zeros((3, sita.shape[0]))

    Z_N, Z_T = shelby_tensor_cch(C, a1, a2, a3, p)

    delta_N = C[2, 2] * Z_N / (1 + C[2, 2] * Z_N)
    delta_T = C[3, 3] * Z_T / (1 + C[3, 3] * Z_T)

    C_eff = np.zeros((6, 6))
    C_eff[0, 0] = C[0, 0] * (1 - ((C[0, 2] / c_1) ** 2) * delta_N)
    C_eff[0, 1] = C[0, 1] * (1 - ((C[0, 2] / (C[0, 1] * C[2, 2])) ** 2) * delta_N)
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

    for kk in range(sita.shape[0]):
        ssita = np.sin(sita[kk]) ** 2
        ccsita = np.cos(sita[kk]) ** 2

        M = (C_eff[1, 1] * ssita + C_eff[3, 3] * ccsita) * (C_eff[3, 3] * ssita + C_eff[2, 2] * ccsita) - ((C_eff[1, 2] + C_eff[3, 3]) ** 2) * ssita * ccsita
        inter_a = C_eff[3, 3] + C_eff[1, 1] * ssita + C_eff[2, 2] * ccsita
        iner_b = np.sqrt(inter_a ** 2 - 4 * M)

        V_p = np.sqrt(inter_a + iner_b) * (1.0 / np.sqrt(2 * density))
        V_sv = np.sqrt(inter_a - iner_b) * (1.0 / np.sqrt(2 * density))
        V_sh = np.sqrt((C_eff[5, 5] * ssita + C_eff[4, 4] * ccsita) / density)

        V_dry[0, kk] = V_p
        V_dry[1, kk] = V_sv
        V_dry[2, kk] = V_sh

    return V_dry, C_eff  # 返回 V_dry 和 C_eff