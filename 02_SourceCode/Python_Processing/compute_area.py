import sys
import numpy as np
from scipy.integrate import quad
import matplotlib.pyplot as plt

# -----------------------------
# 裂隙参数（可根据你的模型修改）
# -----------------------------
b = 1e-4/2        # 最大开度 (m)
c0 = 0.036/2       # 初始半长 (m)
nu = 0.15       # 泊松比
mu0 = 2.59e9      # 剪切模量 (Pa)

P = np.arange(0, 1.02, 0.02)  # 生成从0到1，步长0.02的数组，包含1.00
P = -P * 100e6             # 将所有元素乘以1亿（100MPa）

# -----------------------------
# 函数定义
# -----------------------------
def c_of_P(P, b=b, c0=c0, nu=nu, mu0=mu0):
    """计算应力 P 下的裂隙半长 c(P)"""
    beta = 2*(1 - nu)*c0 / (3*mu0*b)
    return c0 * (1 - beta * P)**(-0.5)

def U_of_x_P(x, P, b=b, c0=c0, nu=nu, mu0=mu0):
    """应力 P 下裂隙的开度分布 U(x,P)"""
    c = c_of_P(P, b, c0, nu, mu0)
    inside = np.abs(x) <= c
    U = np.zeros_like(x)
    U[inside] = 2 * b * (c / c0)**3 * (1 - (x[inside]/c)**2)**1.5
    return U

# def A_of_P(P, b=b, c0=c0, nu=nu, mu0=mu0):
#     """解析公式：裂隙面积 vs 压力"""
#     beta = 2*(1 - nu)*c0 / (3*mu0*b)
#     return (3*np.pi/4) * b * c0 * (1 - beta * P)**(-2)

def A_integral(P):
    """数值积分计算 A(P)=∫U(x,P) dx，用于验证解析式"""
    c = c_of_P(P)
    func = lambda x: 2*b*(c/c0)**3*(1 - (x/c)**2)**1.5
    val, _ = quad(func, -c, c)
    return val

# -----------------------------
# 示例：计算与绘图
# -----------------------------
A = np.array([A_integral(p) for p in P])

plt.figure(figsize=(6,4))
plt.plot(P/1e6, A*1e6, 'b-', lw=2)
plt.xlabel("Stress P (MPa)")
plt.ylabel("Area A (mm²)")
plt.title("Non-elliptical crack area under stress")
plt.grid(True)
plt.tight_layout()
plt.show()

# # 选取一个压力点验证解析式和积分式的差异
# P_test = 2e7  # 20 MPa
# A_num = A_integral(P_test)
# A_exact = A_of_P(P_test)
# print(f"P={P_test/1e6:.1f} MPa  数值积分={A_num:.4e},  解析式={A_exact:.4e},  相对误差={(A_num-A_exact)/A_exact*100:.3f}%")











