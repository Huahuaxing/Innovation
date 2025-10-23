import json
import numpy as np

v_stress = 2118.9
v_shear  = 1254.7
rho      = 2020
K        = 4.829e9
E        = 7.820e9
nu       = 0.23
lam      = 2.71e9
mu       = 3.180e9

Stress = np.linspace(3, 600, 200) * 1e5

# 整理为字典，注意要把numpy数组转为列表
data = {
    "v_stress": v_stress,
    "v_shear": v_shear,
    "rho": rho,
    "K": K,
    "E": E,
    "nu": nu,
    "lam": lam,
    "mu": mu,
    "Stress": Stress.tolist()  # 转为普通list，json才能保存
}

# 写入json文件，带缩进、易读
with open("properties.json", "w") as f:
    json.dump(data, f, indent=4)