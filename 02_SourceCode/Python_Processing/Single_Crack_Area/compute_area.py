import numpy as np
import matplotlib.pyplot as plt
from matplotlib.widgets import Cursor
from scipy.integrate import quad


# ---------------- 子函数部分 ---------------
def U0_of_x(x, b, c0):
    return b * (1 - (x/c0)**2)**1.5

def c_of_P(P, b, c0, nu, mu0):
    """计算应力P下的裂隙半长"""
    beta = 2*(1-nu)*c0 / (3*mu0*b)
    return c0 * (1 - beta * P)**(-0.5)

def integrand(x, c, b, c0):
    """被积函数 U(x,P)"""
    y = 2*b*(c/c0)**3 * (1 - (x/c)**2)**1.5 * (np.abs(x) <= c)
    y[np.abs(x) > c] = 0  # 超过c以外的都为0
    return y

def sigma_close_p(b, c0, E):
    alpha0 = b/c0
    return 3*alpha0*E / (4*(1-nu**2))

def sigma_close_e(b, c0, E):
    alpha0 = b/c0
    return alpha0*E / (4*(1-nu**2))


if __name__ == "__main__":
    # 裂隙参数
    b = 1e-4/2         # 最大开度 (m)
    c0 = 0.036/2       # 初始半长 (m)
    nu = 0.15          # 泊松比
    E = 5.59e9         # 杨氏模量 (Pa)
    mu0 = 2.59e9       # 剪切模量 (Pa)

    # 压力P（负号表示压应力，与python一致，单位：Pa）
    P = np.arange(0, -1.02, -0.02)  # 生成 0, -0.02, ..., -1.00
    P = P * 100e6                   # 转为 Pa

    # 绘图1：裂隙图像
    # 启用交互式模式
    plt.ion()
    x = np.arange(-c0, c0 + 0.001, 0.001)
    U0 = U0_of_x(x, b, c0)
    plt.figure(figsize=(6, 8))

    plt.subplot(2, 1, 1)
    plt.plot(x, U0, 'b-', linewidth=2)
    plt.plot(x, -U0, 'b-', linewidth=2)
    plt.xlabel('x')
    plt.ylabel('y')
    plt.title('crack shape')
    plt.grid(True)

    # # 绘图2：裂隙面积随力的变化
    # A = np.zeros(len(P))
    # for i in range(len(P)):
    #     c = c_of_P(P[i], b, c0, nu, mu0)
    #     A[i] = quad(lambda x_val: integrand(x_val, c, b, c0), -c, c)[0]

    # plt.subplot(2, 1, 2)
    # plt.plot(P/1e6, A*1e6, 'b-', linewidth=2)
    # plt.xlabel('Stress P (MPa)')
    # plt.ylabel('Area (mm^2)')
    # plt.title('Non-elliptical crack area under stress')
    # plt.grid(True)

    # # 绘图3：裂隙随应力变化的图像
    # P_subset = P[::10]  # 每10个取一个
    # c1 = c_of_P(P_subset, b, c0, nu, mu0)

    # plt.figure(figsize=(6, 8))
    # for i in range(len(c1)):
    #     U1 = integrand(x, c1[i], b, c0)
    #     plt.subplot(10, 1, i+1)
    #     plt.plot(x, U1, 'b-')
    #     plt.plot(x, -U1, 'b-')
    #     plt.xlabel('x')
    #     plt.ylabel('y')
    #     plt.title('crack shape')
    # plt.grid(True)
    # plt.tight_layout()
    plt.show()