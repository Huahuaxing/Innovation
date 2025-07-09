import numpy as np

# ------------------------- 材料参数 -------------------------
K = 4.829e9         # 体积模量
MU = 3.180e9        # 剪切模量
E = 40e9            # 杨氏模量（Pa）
nu = 0.25           # 泊松比
rho = 2600          # 密度（kg/m³）

# -------------------- 二阶弹性模量计算 --------------------
def compute_lambda_mu(E, nu):
    lam = E * nu / ((1 + nu) * (1 - 2 * nu))
    mu = E / (2 * (1 + nu))
    return lam, mu

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

def A55(P, A, B, C, lam, mu):
    term1 = mu
    term2 = (mu + B + A/2) * P * (lam + 2*mu) / (mu * (3*lam + 2*mu))
    term3 = (mu + B + A/2) * P * lam / (2 * mu * (3*lam + 2*mu))
    return term1 + term2 - term3

def A44(P, A, B, C, lam, mu):
    return A55(P, A, B, C, lam, mu)  # 等价于 A55（若为各向同性）

def A13(P, A, B, C, lam, mu):
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

def vsv_confined(P, A, B, C, lam, mu, rho):
    a55 = A55(P, A, B, C, lam, mu)
    return np.sqrt(a55 / rho)

def vsh_confined(P, A, B, C, lam, mu, rho):
    a44 = A44(P, A, B, C, lam, mu)
    return np.sqrt(a44 / rho)

# -------------------- 完整 K 表达式（根据论文公式） --------------------
def K_expr(P, A, B, C, lam, mu, theta1_deg=90):
    theta = np.radians(theta1_deg)  # 角度转弧度
    a11 = A11(P, A, B, C, lam, mu)
    a55 = A55(P, A, B, C, lam, mu)
    a12 = A12(P, A, B, C, lam, mu)
    a44 = A44(P, A, B, C, lam, mu)
    
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
def vp_confined(P, A, B, C, lam, mu, rho, theta1_deg=90):
    a11 = A11(P, A, B, C, lam, mu)
    a55 = A55(P, A, B, C, lam, mu)
    K = K_expr(P, A, B, C, lam, mu, theta1_deg)
    return np.sqrt((a11 + a55 + np.sqrt(K)) / rho)

def vsv_confined(P, A, B, C, lam, mu, rho, theta1_deg=90):
    a11 = A11(P, A, B, C, lam, mu)
    a55 = A55(P, A, B, C, lam, mu)
    K = K_expr(P, A, B, C, lam, mu, theta1_deg)
    return np.sqrt((a11 + a55 - np.sqrt(K)) / rho)

def vsh_confined(P, A, B, C, lam, mu, rho, theta1_deg=90):
    a44 = A44(P, A, B, C, lam, mu)
    return np.sqrt(a44 / rho)
