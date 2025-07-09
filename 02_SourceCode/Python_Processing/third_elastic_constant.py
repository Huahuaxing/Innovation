import numpy as np
from scipy.optimize import curve_fit
from utils.acoustoelastic_matrix import vp_confined



lam = E * nu / ((1 + nu) * (1 - 2 * nu))
mu = E / (2 * (1 + nu))


# ------------------------- 拟合接口 -------------------------
def vp_fit_func(P, A, B, C):
    return vp_confined(P, A, B, C, lam, mu, rho)

# ------------------------- 单组拟合函数模板 -------------------------
def fit_single_model(P_data, Vp_data, initial_guess=(1e9, 1e9, 1e9)):
    def fit_func(P, A, B, C):
        return vp_fit_func(P, A, B, C)

    popt, pcov = curve_fit(fit_func, P_data, Vp_data, p0=initial_guess, maxfev=10000)
    return popt  # 返回拟合得到的 A, B, C
