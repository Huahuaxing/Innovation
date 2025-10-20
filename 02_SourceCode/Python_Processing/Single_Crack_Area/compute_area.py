import numpy as np
import matplotlib.pyplot as plt
from matplotlib.widgets import Cursor
from scipy.integrate import quad

class Pcrack:
    '''多边形裂隙类'''
    def __init__(self, b0, c0, E, nu) -> None:
        '''b0:半最大开度, c0:半长, E:杨氏模量, nu:泊松比'''
        self.b0 = b0
        self.c0 = c0
        self.E = E
        self.nu = nu

    def sigma_close(self):
        alpha0 = self.b0/self.c0
        strss_close = 3*alpha0*self.E / (4*(1-self.nu**2))
        print(f"对于初始条件：b0={self.b0}m, c0={self.c0}m, E={self.E/1e9}GPa, nu={self.nu},裂隙的闭合应力为：{strss_close/1e6}MPa")
        return strss_close


# ---------------- 相关函数 ---------------
def U0_of_x(x, b, c0):
    x = np.asarray(x)
    z = 1.0 - (x / c0)**2
    z = np.maximum(z, 0.0)          # 把负值截为0，避免NaN
    return b * z**1.5

def c_of_P(P, b, c0, nu, mu0):
    """计算应力P下的裂隙半长"""
    beta = 2*(1-nu)*c0 / (3*mu0*b)
    return c0 * (1 - beta * P)**(-0.5)

def integrand(x, c, b, c0):
    x = np.asarray(x)
    y = np.zeros_like(x, dtype=float)
    mask = np.abs(x) <= c
    if np.any(mask):
        z = 1.0 - (x[mask] / c)**2
        z = np.maximum(z, 0.0)
        y[mask] = 2.0 * b * (c / c0)**3 * z**1.5
    return y

def sigma_close_p(b, c0, E, nu):
    alpha0 = b/c0
    return 3*alpha0*E / (4*(1-nu**2))

def sigma_close_e(b, c0, E, nu):
    alpha0 = b/c0
    return alpha0*E / (2*(1-nu**2))


if __name__ == "__main__":
    b = 1e-4/2         # 最大开度 (m)
    c0 = 0.036/2       # 初始半长 (m)
    nu = 0.15          # 泊松比
    E = 5.56e9         # 杨氏模量 (Pa)
    mu0 = 2.59e9       # 剪切模量 (Pa)

    # 压力P（负号表示压应力，单位：Pa）
    P = np.arange(0, -1.02, -0.02)  # 生成 0, -0.02, ..., -1.00
    P = P * 100e6                   # 转为 Pa
    x = np.arange(-c0, c0 + 0.001, 0.001)

    bigCrack = Pcrack(2e-4/2, 0.036/2, 7.82e9, 0.23)
    smallCrack = Pcrack(1e-4/2, 0.036/2, 7.82e9, 0.23)

    bigCrack.sigma_close()
    smallCrack.sigma_close()

    # print(f"椭圆裂隙的闭合应力为：{sigma_close_e(b, c0, E, nu)/1e6} MPa")
    # print(f"非椭圆裂隙A的闭合应力为：{sigma_close_p(b, c0, E, nu)/1e6} MPa")

    # # 面积求解
    # A = np.zeros(len(P))
    # for i in range(len(P)):
    #     c = c_of_P(P[i], b, c0, nu, mu0)
    #     A[i] = quad(lambda x_val: integrand(x_val, c, b, c0), -c, c)[0]

    # # 图像1:裂隙随应力变化的图像
    # P_subset = P[::5]  # 每10个取一个
    # c1 = c_of_P(P_subset, b, c0, nu, mu0)
    # A3 = A[::5]

    # fig = plt.figure(figsize=(14, 10), constrained_layout=True)
    # gs = fig.add_gridspec(nrows=len(P_subset), ncols=2, width_ratios=[1, 1])

    # # 右侧大图：应力-面积（占两列的所有行）
    # ax_right = fig.add_subplot(gs[:, 1])
    # ax_right.plot(P/1e6, A*1e6, 'b-', linewidth=2)
    # ax_right.set_xlabel('Stress P (MPa)')
    # ax_right.set_ylabel('Area (mm^2)')
    # ax_right.set_title('Area vs Stress')
    # ax_right.grid(True)

    # # 左侧 10 个小图（上到下）
    # for i, ci in enumerate(c1):
    #     ax = fig.add_subplot(gs[i, 0])
    #     U1 = integrand(x, ci, b, c0)
    #     ax.plot(x, U1/2, 'b-')
    #     ax.plot(x, -U1/2, 'b-')
    #     ax.set_title(f"P={P_subset[i]/1e6:.2f} MPa  A={A3[i]*1e6:.3f} mm$^2$")
    #     ax.grid(True)
    #     ax.set_ylim(-6e-5, 6e-5)
    #     # 只在最下面的小图显示 x 轴标签
    #     if i < len(c1)-1:
    #         ax.set_xticklabels([])
    # plt.show()