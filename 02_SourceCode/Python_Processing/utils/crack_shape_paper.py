import numpy as np


# ---------------- 论文中非椭圆裂隙相关函数 ---------------
def U0_of_x(x, b0, c0):
    '''
    裂隙形态函数
    给定裂隙半长轴和半短轴，输出x坐标上的裂隙开度U0(x)
    '''
    x = np.asarray(x)
    z = 1.0 - (x / c0)**2
    z = np.maximum(z, 0.0)          # 把负值截为0，避免NaN
    return b0 * z**1.5


def c_of_P(P, b0, c0, nu, mu0):
    """
    计算应力P下的裂隙最大开度c
    """
    beta = 2*(1-nu)*c0 / (3*mu0*b0)
    return c0 * (1 - beta * P)**(-0.5)


def U_of_x_P(x, c, b0, c0):
    '''
    应力P作用下的裂隙形态函数，输出x坐标上的裂隙开度U(x, P)
    '''
    x = np.asarray(x)
    y = np.zeros_like(x, dtype=float)
    mask = np.abs(x) <= c
    if np.any(mask):
        z = 1.0 - (x[mask] / c)**2
        z = np.maximum(z, 0.0)
        y[mask] = 2.0 * b0 * (c / c0)**3 * z**1.5
    return y

def sigma_close_p(b0, c0, E, nu):
    '''
    非椭圆裂隙闭合应力P
    '''
    alpha0 = b0/c0
    return 3*alpha0*E / (4*(1-nu**2))


def sigma_close_e(b0, c0, E, nu):
    '''
    椭圆裂隙闭合应力P
    '''
    alpha0 = b0/c0
    return alpha0*E / (2*(1-nu**2))