import numpy as np
from scipy.optimize import curve_fit
import acoustoelastic_matrix as am
import json
import matplotlib.pyplot as plt
import goodness_of_fit as gof
from lmfit import Model

# ------------------------- 基本参数定义 -------------------------
lam = am.lam    # Lamé第一参数 (Pa)
mu = am.mu      # 剪切模量/Lamé第二参数 (Pa)
rho = am.rho    # 密度 (kg/m³)
P = am.P        # 压力数组 (Pa)
sita = 90       # 波速角度 (度)
# 加载实验测量的纵波速度数据 (m/s)
vp_ellipse_data = np.loadtxt(f'.\\05_ProcessedData\\velocity\\{sita}_degree\\vp_ellipse.csv', delimiter=',')
print('--------------------------------')
print('vp_ellipse_data 变化范围（m/s）', vp_ellipse_data[:, 0].min(), vp_ellipse_data[:, 0].max())
print('--------------------------------')

if __name__ == "__main__":
    # 初始猜测值 (无量纲，归一化后的GPa单位)
    guess = (99, 99, 99)  # A, B, C的初始值

    def fit_function_scaled(P_scaled, A, B, C):
        # 在函数内部转换回原始单位
        return am.vp_uniaxial(P_scaled * 1e6, A * 1e9, B * 1e9, C * 1e9, lam, mu, rho)


    def fit_function_rho_v2(P_scaled, A, B, C):
        """
        用rho*v^2计算弹性常数
        """
        return am.rho_vp2(P_scaled * 1e6, A * 1e9, B * 1e9, C * 1e9, lam, mu)

    # ------------------------- lmfit拟合 -------------------------
    def lmfit_fit(P_data, Vp_data):
        P_scaled = P_data / 1e6  # 压力单位转换为MPa

        model = Model(fit_function_rho_v2, independent_vars=['P_scaled'])
        params = model.make_params(A=guess[0], B=guess[1], C=guess[2])  # 单位为GPa
        
        # 设置参数边界，防止发散
        params['A'].set(min=-1e4, max=1e4)  # 合理范围 (GPa)
        params['B'].set(min=-1e4, max=1e4)  # 合理范围 (GPa)
        params['C'].set(min=-1e4, max=1e4)  # 合理范围 (GPa)
        
        result = model.fit(Vp_data, params, P_scaled=P_scaled)
        
        # 还原为原始单位 (Pa)
        best_values_original = {k: v * 1e9 for k, v in result.best_values.items()}
        print("还原后的最佳参数 (Pa):", best_values_original)
        
        print(result.fit_report())
        print('--------------------------------')

        # 绘制拟合结果
        plt.title('lmfit拟合')
        plt.plot(P_data, Vp_data, color="#72CD28", label='原始数据')
        # plt.plot(P_data, fit_function_scaled(P_scaled, result.best_values['A'], result.best_values['B'], result.best_values['C']), color="#EBBD43", label='拟合数据')
        plt.plot(P_data, fit_function_scaled(P_scaled, -1000, -419, -340), color="#EBBD43", label='拟合数据')
        plt.legend() 
        plt.rcParams['font.sans-serif'] = ['SimHei']  # 用来正常显示中文标签
        plt.rcParams['axes.unicode_minus'] = False  # 用来正常显示负号
        plt.show()

        return result.best_values


    # ------------------------- scipy拟合 -------------------------
    def scipy_fit(P_data, Vp_data):
        P_scaled = P_data / 1e6  # 压力单位转换为MPa
        popt, _ = curve_fit(fit_function_rho_v2, P_scaled, Vp_data, p0=guess, maxfev=10000)
        print('scipy拟合结果：', popt)
        print('--------------------------------')

        # 绘制拟合结果
        plt.title('scipy拟合')
        plt.plot(P_data, Vp_data, color="#72CD28", label='原始数据')
        plt.plot(P_data, fit_function_scaled(P_scaled, popt[0], popt[1], popt[2]), color="#EBBD43", label='拟合数据')
        plt.legend() 
        plt.rcParams['font.sans-serif'] = ['SimHei']  # 用来正常显示中文标签
        plt.rcParams['axes.unicode_minus'] = False  # 用来正常显示负号
        plt.show()
        return popt

    # 执行拟合
    ABCs_ellipse_lmfit = lmfit_fit(P, vp_ellipse_data[:, 0])  # 返回归一化的三阶弹性常数 (GPa)
    ABCs_ellipse_scipy = scipy_fit(P, vp_ellipse_data[:, 0])  # 返回归一化的三阶弹性常数 (GPa)


    # # 保存拟合波速
    # np.savetxt(f'.\\05_ProcessedData\\velocity\\{sita}_degree_fit\\vp_ellipse_fit.csv', vp_ellipse_fit, delimiter=',')
    # np.savetxt(f'.\\05_ProcessedData\\velocity\\{sita}_degree_fit\\vp_polygon_fit.csv', vp_polygon_fit, delimiter=',')

    # 保存拟合参数
    # np.savetxt(f'.\\05_ProcessedData\\third_elastic_constant\\{sita}_degree\\ABCs_ellipse.csv', ABCs_ellipse, delimiter=',')
    # np.savetxt(f'.\\05_ProcessedData\\third_elastic_constant\\{sita}_degree\\ABCs_polygon.csv', ABCs_polygon, delimiter=',')

    # # 保存拟合参数误差
    # np.savetxt(f'.\\05_ProcessedData\\third_elastic_constant\\{sita}_degree\\ABCs_ellipse_err.csv', ABCs_ellipse_err, delimiter=',')
    # np.savetxt(f'.\\05_ProcessedData\\third_elastic_constant\\{sita}_degree\\ABCs_polygon_err.csv', ABCs_polygon_err, delimiter=',')

