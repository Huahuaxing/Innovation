import numpy as np
from scipy.optimize import curve_fit
import acoustoelastic_matrix as am
import json
import matplotlib.pyplot as plt
import goodness_of_fit as gof
from lmfit import Model

# ------------------------- 基本参数定义 -------------------------
lam = am.lam
mu = am.mu
rho = am.rho
P_data = am.P
sita = 90

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
    popt, pcov = curve_fit(vp_fit_func, P_data, Vp_data, p0=initial_guess, maxfev=10000)
    perr = np.sqrt(np.diag(pcov))
    return popt, perr  # 返回拟合得到的 A, B, C, 以及误差


if __name__ == "__main__":

    vp_ellipse_data = np.loadtxt(f'.\\05_ProcessedData\\velocity\\{sita}_degree\\vp_ellipse.csv', delimiter=',')
    print('--------------------------------')
    print('vp_ellipse_data 变化范围（m/s）', vp_ellipse_data[:, 0].min(), vp_ellipse_data[:, 0].max())
    print('--------------------------------')

    # ------------------------- lmfit拟合 -------------------------
    def lmfit_fit(P_data, Vp_data):
        def fit_function(P, A, B, C):
            return am.vp_confined2(P, A, B, C, lam, mu, rho) 

        model = Model(fit_function, independent_vars=['P'])
        params = model.make_params(A=1e9, B=1e9, C=1e9)
        result = model.fit(Vp_data, params, P=P_data)
        print(result.fit_report())
        print('--------------------------------')

        plt.title('lmfit拟合')
        plt.plot(P_data, Vp_data, color="#72CD28", label='原始数据')
        plt.plot(P_data, fit_function(P_data, result.best_values['A'], result.best_values['B'], result.best_values['C']), color="#EBBD43", label='拟合数据')
        plt.legend() 
        plt.rcParams['font.sans-serif'] = ['SimHei']  # 用来正常显示中文标签
        plt.rcParams['axes.unicode_minus'] = False  # 用来正常显示负号
        plt.show()

        return result.best_values


    # ------------------------- scipy拟合 -------------------------
    def scipy_fit(P_data, Vp_data):
        def fit_function(P, A, B, C):
            return am.vp_confined2(P, A, B, C, lam, mu, rho)

        popt, _ = curve_fit(fit_function, P_data, Vp_data, p0=(1e9, 1e9, 1e9), maxfev=10000)
        print('--------------------------------')
        print('scipy拟合结果：', popt)
        print('--------------------------------')

        plt.title('scipy拟合')
        plt.plot(P_data, Vp_data, color="#72CD28", label='原始数据')
        plt.plot(P_data, fit_function(P_data, popt[0], popt[1], popt[2]), color="#EBBD43", label='拟合数据')
        plt.legend() 
        plt.rcParams['font.sans-serif'] = ['SimHei']  # 用来正常显示中文标签
        plt.rcParams['axes.unicode_minus'] = False  # 用来正常显示负号
        plt.show()
        return popt

    ABCs_ellipse_lmfit = lmfit_fit(P_data, vp_ellipse_data[:, 0])
    ABCs_ellipse_scipy = scipy_fit(P_data, vp_ellipse_data[:, 0])


    # # 保存拟合波速
    # np.savetxt(f'.\\05_ProcessedData\\velocity\\{sita}_degree_fit\\vp_ellipse_fit.csv', vp_ellipse_fit, delimiter=',')
    # np.savetxt(f'.\\05_ProcessedData\\velocity\\{sita}_degree_fit\\vp_polygon_fit.csv', vp_polygon_fit, delimiter=',')

    # 保存拟合参数
    # np.savetxt(f'.\\05_ProcessedData\\third_elastic_constant\\{sita}_degree\\ABCs_ellipse.csv', ABCs_ellipse, delimiter=',')
    # np.savetxt(f'.\\05_ProcessedData\\third_elastic_constant\\{sita}_degree\\ABCs_polygon.csv', ABCs_polygon, delimiter=',')

    # # 保存拟合参数误差
    # np.savetxt(f'.\\05_ProcessedData\\third_elastic_constant\\{sita}_degree\\ABCs_ellipse_err.csv', ABCs_ellipse_err, delimiter=',')
    # np.savetxt(f'.\\05_ProcessedData\\third_elastic_constant\\{sita}_degree\\ABCs_polygon_err.csv', ABCs_polygon_err, delimiter=',')

