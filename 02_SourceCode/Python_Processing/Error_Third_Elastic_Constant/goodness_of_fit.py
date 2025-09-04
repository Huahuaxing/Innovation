import numpy as np
# #################################拟合优度R^2的计算######################################
def __sst(y_no_fitting):
    """
    计算SST(total sum of squares) 总平方和
    :param y_no_predicted: List[int] or array[int] 待拟合的y
    :return: 总平方和SST
    """
    y_mean = sum(y_no_fitting) / len(y_no_fitting)
    s_list =[(y - y_mean)**2 for y in y_no_fitting]
    sst = sum(s_list)
    return sst


def __ssr(y_fitting, y_no_fitting):
    """
    计算SSR(regression sum of squares) 回归平方和
    :param y_fitting: List[int] or array[int]  拟合好的y值
    :param y_no_fitting: List[int] or array[int] 待拟合y值
    :return: 回归平方和SSR
    """
    y_mean = sum(y_no_fitting) / len(y_no_fitting)
    s_list =[(y - y_mean)**2 for y in y_fitting]
    ssr = sum(s_list)
    return ssr


def __sse(y_fitting, y_no_fitting):
    """
    计算SSE(error sum of squares) 残差平方和
    :param y_fitting: List[int] or array[int] 拟合好的y值
    :param y_no_fitting: List[int] or array[int] 待拟合y值
    :return: 残差平方和SSE
    """
    s_list = [(y_no_fitting[i] - y_fitting[i])**2 for i in range(len(y_fitting))]
    sse = sum(s_list)
    return sse


def goodness_of_fit(y_fitting, y_no_fitting):
    """
    计算拟合优度R^2
    :param y_fitting: List[int] or array[int] 拟合好的y值
    :param y_no_fitting: List[int] or array[int] 待拟合y值
    :return: 拟合优度R^2
    """
    SSR = __ssr(y_fitting, y_no_fitting)
    SST = __sst(y_no_fitting)
    SSE = __sse(y_fitting, y_no_fitting)
    rr1 = SSR /SST
    rr2 = 1 - SSE /SST
    if rr1 != rr2:
        print("rr1和rr2计算结果不一致")
    if rr1 == rr2:
        print("rr1和rr2计算结果一致")
    return rr2


def r2_score(y_fitting, y_no_fitting):
    """
    最安全的 R² 公式：1 - SSE/SST
    不依赖 SSE+SSR=SST 恒等式，可避免 >1 异常
    """
    y_fitting = np.asarray(y_fitting, dtype=float)
    y_no_fitting = np.asarray(y_no_fitting, dtype=float)

    ss_tot = np.sum((y_no_fitting - y_no_fitting.mean())**2)
    ss_err = np.sum((y_no_fitting - y_fitting)**2)
    return 1.0 - ss_err / ss_tot