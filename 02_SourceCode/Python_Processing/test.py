import numpy as np
import matplotlib.pyplot as plt
import sys
import os


def extract_E_nu_from_C(C):
    """
    从一个 6x6 各向同性刚度矩阵中提取杨氏模量 E 和泊松比 ν
    C: shape (..., 6, 6)
    返回：E, ν
    """
    C11 = C[:, 0, 0]
    C12 = C[..., 0, 1]

    # 防止除零
    denom = C11 + C12
    denom[denom == 0] = 1e-12

    E = (C11 - C12) * (C11 + 2 * C12) / denom
    nu = C12 / denom
    return E, nu


# 假设你的数组叫 stiffness_array，形状 (200, 5, 6, 6, 6)
# 遍历最后一维的6个刚度矩阵，并提取E和ν
def compute_E_nu_batch(C_eff):
    """
    处理整个数组：shape = (200, 5, 6, 6, 6)
    返回：
        E_vals: shape (200, 6)
        nu_vals: shape (200, 6)
    """
    E_vals = np.zeros((200, 6))
    nu_vals = np.zeros((200, 6))

    for i in range(6):
        C = np.mean(C_eff, axis=1)[..., i]
        E, nu = extract_E_nu_from_C(C)
        E_vals[..., i] = E
        nu_vals[..., i] = nu

    return E_vals, nu_vals


C_eff = np.random.rand(200, 5, 6, 6, 6)  # 生成均匀分布的随机数

E, nu = compute_E_nu_batch(C_eff)

print(E)
print(nu)