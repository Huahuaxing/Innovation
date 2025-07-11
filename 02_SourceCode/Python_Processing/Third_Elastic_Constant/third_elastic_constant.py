import numpy as np
from scipy.optimize import curve_fit
import utils.acoustoelastic_matrix as am
import json

# ------------------------- 基本参数定义 -------------------------
lam, mu = am.lam, am.mu
rho = am.rho
P_data = am.P

# ------------------------- 单组拟合函数模板 -------------------------
def fit_single_model(P_data, Vp_data, initial_guess=(1e9, 1e9, 1e9)):

    def vp_fit_func(P, A, B, C):
        """
        根据三阶弹性常数 A, B, C 及压力 P，利用 vp_confined2 公式计算预测的 vp。
        P: 压力数组
        A, B, C: 三阶弹性常数
        返回: 预测的 vp 数组
        """
        return am.vp_confined2(P, A, B, C, lam, mu, rho)

    # curve_fit 进行最小二乘拟合
    popt, pcov = curve_fit(vp_fit_func, P_data, Vp_data, p0=initial_guess, maxfev=5000)
    return popt  # 返回拟合得到的 A, B, C


if __name__ == "__main__":

    ABCs_ellipse = []   # (6, 3)
    ABCs_polygon = []   # (6, 3)

    for i in range(1, 7):
        v_ellipse_data = np.loadtxt('.\\05_ProcessedData\\velocity\\V_ellipse_{}.csv'.format(i), delimiter=',')[0, :]
        v_polygon_data = np.loadtxt('.\\05_ProcessedData\\velocity\\V_polygonal_{}.csv'.format(i), delimiter=',')[0, :]

        ABCs_ellipse.append(fit_single_model(P_data, v_ellipse_data))
        ABCs_polygon.append(fit_single_model(P_data, v_polygon_data))

    # 保存为json
    with open('.\\05_ProcessedData\\third_elastic_constant\\ABCs_ellipse.json', 'w') as f:
        json.dump(np.array(ABCs_ellipse).tolist(), f, indent=4)
    with open('.\\05_ProcessedData\\third_elastic_constant\\ABCs_polygon.json', 'w') as f:
        json.dump(np.array(ABCs_polygon).tolist(), f, indent=4)

