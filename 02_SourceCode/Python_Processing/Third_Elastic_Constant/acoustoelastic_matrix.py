import numpy as np
from scipy.optimize import curve_fit
import goodness_of_fit as gof
import matplotlib.pyplot as plt
from lmfit import Model

# ------------------------- 应力数组 -------------------------
P = np.linspace(3, 600, 200) * 1e5 # Pa
# P = P[20:100]

# ------------------------- 基质弹性参数 -------------------------
# 曹老师comsol模型设置的
v_stress = 2118.9   # 纵波波速 m/s
v_shear = 1254.7    # 横波波速 m/s
rho = 2020          # 密度 kg/m^3
K = 4.829e9         # 体积模量 Pa
mu = 3.180e9        # 剪切模量 Pa
E = 7.820e9         # 杨氏模量 Pa
nu = 0.23           # 泊松比
lam = 2.71e9        # 拉梅常数 Pa
# lam = E * nu / ((1 + nu) * (1 - 2 * nu))

# -------------------- 附录A 第二组公式（单轴预应力） --------------------
def A11(P, A, B, C, lam, mu):
    term1 = lam + 2 * mu
    term2 = (3*lam + 6*mu + 2*C + 6*B + 2*A) * P * (lam + 2*mu) / (mu * (3*lam + 2*mu))
    term3 = (2*B + 2*C - lam - 2*mu) * P * lam / (2 * mu * (3*lam + 2*mu))
    return term1 + term2 - term3

def A12(P, A, B, C, lam, mu):
    return 0

def A33(P, A, B, C, lam, mu):
    term1 = lam + 2 * mu
    term2 = (2*B + 2*C - lam - 2*mu) * P * (lam + 2*mu) / (mu * (3*lam + 2*mu))
    term3 = (3*lam + 6*mu + 2*C + 6*B + 2*A) * P * lam / (2 * mu * (3*lam + 2*mu))
    return term1 + term2 - term3

def A55(P, A, B, lam, mu):
    term1 = mu
    term2 = (mu + B + A/2) * P * (lam + 2*mu) / (mu * (3*lam + 2*mu))
    term3 = (mu + B + A/2) * P * lam / (2 * mu * (3*lam + 2*mu))
    return term1 + term2 - term3
 
def A44(P, A, B, lam, mu):
    return A55(P, A, B, lam, mu)  # 等价于 A55（若为各向同性）
    # return np.zeros_like(P)

def A13(P, B, C, lam, mu):
    term1 = lam
    term2 = (lam + 2*C + 2*B) * P * (lam + 2*mu) / (mu * (3*lam + 2*mu))
    term3 = (2*B + 2*C + lam) * P * lam / (2 * mu * (3*lam + 2*mu))
    return term1 + term2 - term3

def A15(P, A, B, C, lam, mu):
    return np.zeros_like(P)

def A35(P, A, B, C, lam, mu):
    return np.zeros_like(P)

# -------------------- 声弹性波速计算 1.各向同性--------------------
def vp_confined(P, A, B, C, lam, mu, rho):
    a33 = A33(P, A, B, C, lam, mu)
    return np.sqrt(a33 / rho)

def vsv_confined(P, A, B, lam, mu, rho):
    a55 = A55(P, A, B, lam, mu)
    return np.sqrt(a55 / rho)

def vsh_confined(P, A, B, lam, mu, rho):
    a44 = A44(P, A, B, lam, mu)
    return np.sqrt(a44 / rho)

# -------------------- 完整 K 表达式（根据论文公式） --------------------
def K_expr(P, A, B, C, lam, mu, theta1_deg):
    theta = np.radians(theta1_deg)  # 角度转弧度
    a11 = A11(P, A, B, C, lam, mu)
    a55 = A55(P, A, B, lam, mu)
    a12 = A12(P, A, B, C, lam, mu)
    a44 = A44(P, A, B, lam, mu)
    
    K = (4 * a11**2 * np.sin(theta)**4
         - 8 * a11 * a55 * np.sin(theta)**4
         - 4 * a12**2 * np.sin(theta)**4
         - 8 * a12 * a55 * np.sin(theta)**4
         + 4 * a11**2 * np.sin(theta)**2
         + 8 * a11 * a44 * np.sin(theta)**2
         + 4 * a12**2 * np.sin(theta)**2
         + 8 * a12 * a44 * np.sin(theta)**2
         + (a11 - a44)**2)
    return K

# -------------------- 波速计算 2.对称面内如sita2=0--------------------
def vp_confined2(P, A, B, C, lam, mu, rho, theta1_deg=0):
    a11 = A11(P, A, B, C, lam, mu)
    a55 = A55(P, A, B, lam, mu)
    K = K_expr(P, A, B, C, lam, mu, theta1_deg)
    return np.sqrt((a11 + a55 + np.sqrt(K)) / rho)

def vsv_confined2(P, A, B, C, lam, mu, rho, theta1_deg=0):
    a11 = A11(P, A, B, C, lam, mu)
    a55 = A55(P, A, B, lam, mu)
    K = K_expr(P, A, B, C, lam, mu, theta1_deg)
    return np.sqrt((a11 + a55 - np.sqrt(K)) / rho)

def vsh_confined2(P, A, B, lam, mu, rho):
    a44 = A44(P, A, B, lam, mu)
    return np.sqrt(a44 / rho)


if __name__ == '__main__':
    # 在acoustoelastic_matrix.py中，修改变量名
    vsh_data = np.loadtxt('.\\05_ProcessedData\\velocity\\90_degree\\vsh_ellipse.csv', delimiter=',')
    a44_data = vsh_data**2 * rho  # 改名为a44_data而不是a44

    # # 在拟合前检查数据
    # plt.figure(figsize=(10, 6))
    # plt.plot(P, a44_data)
    # plt.title('a44 data before fitting')
    # plt.xlabel('Pressure (Pa)')
    # plt.ylabel('a44')
    # plt.grid(True)
    # plt.show()

    def fit_lmfit(P, a44_data):
        # 在拟合前归一化数据
        P_scaled = P / 1e6
        a44_scaled = a44_data / 1e9

        def fit_function_scaled1(P_scaled, A, B):
            # 在函数内部转换回原始单位
            return A55(P_scaled * 1e6, A * 1e9, B * 1e9, lam, mu) / 1e9

        def fit_function(P, A, B):
            return A55(P, A, B, lam, mu)

        model = Model(fit_function_scaled1, independent_vars=['P_scaled'])
        params = model.make_params(A=10, B=10)
        result = model.fit(a44_scaled[:, 0], params, P_scaled=P_scaled)
        print('--------------------------------')
        print(result.fit_report())

        best_params = result.best_values
        print('--------------------------------')
        print('vsh_data 变化范围（m/s）', vsh_data[:, 0].min(), vsh_data[:, 0].max())
        print('A44 变化范围（MPa）', a44_scaled[:, 0].min(), a44_scaled[:, 0].max())
        print('lmfit拟合结果：', best_params)
        print('A44拟合值变化范围', fit_function_scaled1(P_scaled, best_params['A'], best_params['B']).min(), fit_function_scaled1(P_scaled, best_params['A'], best_params['B']).max())
        plt.title('lmfit拟合')
        plt.plot(P, a44_scaled[:, 0], color="#72CD28", label='原始数据')
        plt.plot(P, fit_function_scaled1(P_scaled, best_params['A'], best_params['B']), color="#EBBD43", label='拟合数据')
        plt.legend() 
        plt.rcParams['font.sans-serif'] = ['SimHei']  # 用来正常显示中文标签
        plt.rcParams['axes.unicode_minus'] = False  # 用来正常显示负号


    def fit_scipy(P, a44_data):
        # 缩放
        P_scaled   = P / 1e6      # MPa
        a44_scaled = a44_data / 1e6  # MPa

        # 拟合函数：输入 MPa，内部还原到 Pa；输出 MPa
        def fit_function_scaled(P_mpa, A, B):
            P_pa = P_mpa * 1e6                       # ← 用形参 P_mpa
            a44_pa = A55(P_pa, A*1e9, B*1e9, lam, mu)
            return a44_pa / 1e6                      # 返回 MPa

        # 拟合（只示范 SciPy；lmfit 同理）
        p0 = [0.001, 0.001]             # A,B 的初猜（单位 MPa）
        (A_mpa, B_mpa), _ = curve_fit(fit_function_scaled,
                                    P_scaled, a44_scaled[:, 0],
                                    p0=p0,
                                    maxfev=50000)
        print('--------------------------------')
        print('scipy拟合结果：', A_mpa, B_mpa)
        print('A44拟合值变化范围', fit_function_scaled(P_scaled, A_mpa, B_mpa).min(), fit_function_scaled(P_scaled, A_mpa, B_mpa).max())
        print('--------------------------------')
        plt.title('scipy拟合')
        plt.plot(P_scaled, a44_scaled[:, 0], color="#72CD28", label='原始数据')
        plt.plot(P_scaled, fit_function_scaled(P_scaled, A_mpa, B_mpa), color="#EBBD43", label='拟合数据')
        plt.legend() 
        plt.rcParams['font.sans-serif'] = ['SimHei']  # 用来正常显示中文标签
        plt.rcParams['axes.unicode_minus'] = False  # 用来正常显示负号

    fit_lmfit(P, a44_data)
    plt.show()
    fit_scipy(P, a44_data)
    plt.show()


    

#     # 利用这个A44作为实验值，根据A44=A55，对ABC进行拟合
#     def fit_single_model(P, a44_data, initial_guess=(1e6, 1e6, 1e6)):  # 降低初值量级
#         def fit_function(P, A, B, C):
#             return A55(P, A, B, C, lam, mu)
#         # 添加边界约束
#         bounds = ([-1e10, -1e10, -1e10], [1e10, 1e10, 1e10])
#         ABC, err = curve_fit(fit_function, P, a44_data, p0=initial_guess, bounds=bounds, maxfev=100000)
#         return ABC, err

#     ABCs_ellipse = []
#     for i in range(6):
#         ABC, err = fit_single_model(P, a44_data[:, i])
#         ABCs_ellipse.append(ABC)
#     ABCs_ellipse = np.array(ABCs_ellipse)
#     print(ABCs_ellipse)

#    # 计算每组ABC的拟合波速，结果 shape (200, 6)
#     vsh_ellipse_fit = np.column_stack([
#         vsh_confined2(P, ABCs_ellipse[i, 0], ABCs_ellipse[i, 1], ABCs_ellipse[i, 2], lam, mu, rho)
#         for i in range(6)
#     ])

#     rr = gof.goodness_of_fit(vsh_ellipse_fit[:, 0], vsh_data[:, 0])
#     print("拟合优度为:", rr)

#     plt.plot(P, vsh_data[:, 0], color="#72CD28", label='原始数据')
#     plt.plot(P, vsh_ellipse_fit[:, 0], color="#EBBD43", label='拟合数据')
#     plt.legend() 
#     plt.rcParams['font.sans-serif'] = ['SimHei']  # 用来正常显示中文标签
#     plt.rcParams['axes.unicode_minus'] = False  # 用来正常显示负号
#     plt.show()
    
