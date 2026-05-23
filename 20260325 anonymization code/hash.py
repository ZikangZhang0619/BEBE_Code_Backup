import hmac
import hashlib
import pandas as pd


# ============================================================
# 配置区：只需修改这里
# ============================================================

INPUT_FILE1  = "/Users/zikangzhang/Desktop/Predoc/BEBE/04_Code/0_Data Anonymization/data/contact_list.dta"
INPUT_FILE2  = "/Users/zikangzhang/Desktop/Predoc/BEBE/04_Code/0_Data Anonymization/data/anonymized_cluster_data.dta"

OUTPUT_FILE1 = "/Users/zikangzhang/Desktop/Predoc/BEBE/04_Code/0_Data Anonymization/data/id_mapping_confidential.xlsx"
OUTPUT_FILE2 = "/Users/zikangzhang/Desktop/Predoc/BEBE/04_Code/0_Data Anonymization/output/anonymized_cluster_mapping.xlsx"

# 密钥：通过安全渠道与同事共享，不要上传到 git 或发邮件明文传输
SECRET_KEY = "your_shared_secret_key_here"

# 与现有 family_id 保持一致
HASH_LENGTH = 8


# ============================================================
# 核心函数
# ============================================================

def compute_hmac(value: str, key: str) -> str:
    """
    对单个字符串计算 HMAC-SHA256，返回前 HASH_LENGTH 位十六进制字符串。
    """
    h = hmac.new(
        key.encode("utf-8"),
        value.encode("utf-8"),
        hashlib.sha256
    )
    return h.hexdigest()[:HASH_LENGTH]


def normalize_value(x) -> str:
    """
    将输入统一转成稳定字符串：
    - 去掉前后空格
    - 缺失值报错
    - 若是类似 123.0，则转成 123
    """
    if pd.isna(x):
        raise ValueError("存在缺失值，无法进行哈希")

    s = str(x).strip()

    # 处理 Stata 数值导入后可能出现的 '123.0'
    try:
        num = float(s)
        if num.is_integer():
            s = str(int(num))
    except ValueError:
        pass

    if s == "":
        raise ValueError("存在空字符串，无法进行哈希")

    return s


def anonymize_contact_list(df: pd.DataFrame) -> pd.DataFrame:
    """
    contact_list:
    1. 对住院号生成 family_id
    2. 拆成母亲行和父亲行
    3. 输出供后续匹配使用的 confidential mapping
    """
    df = df.copy()

    # --- Step 1: 规范化住院号并生成 family_id ---
    df["hospital_id"] = df["住院号"].apply(normalize_value)
    df["family_id"] = df["hospital_id"].apply(lambda x: compute_hmac(x, SECRET_KEY))

    # family_id 唯一性检查
    if df["family_id"].nunique() != len(df):
        raise ValueError("family_id 存在重复，请检查住院号或增加 HASH_LENGTH")
    print(f"✅ family_id 唯一性验证通过，共 {len(df)} 条记录")

    # --- Step 2: 保留需要的列 ---
    keep_cols = [
        "招募人员", "组别", "hospital_id", "母亲姓名", "母亲电话",
        "父亲姓名", "父亲电话", "宝宝性别", "TripleP编号", "family_id"
    ]
    df = df[keep_cols]

    # --- Step 3: 拆分母亲 / 父亲 ---
    mother = (
        df.drop(columns=["父亲姓名", "父亲电话"])
          .rename(columns={"母亲姓名": "lastname", "母亲电话": "phone"})
          .assign(mother=1)
    )

    father = (
        df.drop(columns=["母亲姓名", "母亲电话"])
          .rename(columns={"父亲姓名": "lastname", "父亲电话": "phone"})
          .assign(mother=0)
    )

    result = pd.concat([mother, father], ignore_index=True)

    # --- Step 4: 英文列名 ---
    result = result.rename(columns={
        "招募人员": "recruiter",
        "组别": "group",
        "宝宝性别": "baby_sex",
        "TripleP编号": "tripleP_id",
    })

    return result


def anonymize_cluster_data(df: pd.DataFrame) -> pd.DataFrame:
    """
    input2:
    1. 用 hospital_id 按同样方法生成 family_id
    2. 对 cluster_var 原地进行哈希假名化
    3. 删除 hospital_id
    """
    df = df.copy()

    if "hospital_id" not in df.columns:
        raise ValueError("INPUT_FILE2 中未找到变量 'hospital_id'")
    if "cluster_var" not in df.columns:
        raise ValueError("INPUT_FILE2 中未找到变量 'cluster_var'")

    # --- Step 1: 用 hospital_id 生成 family_id ---
    df["hospital_id"] = df["hospital_id"].apply(normalize_value)
    df["family_id"] = df["hospital_id"].apply(lambda x: compute_hmac(x, SECRET_KEY))

    # --- Step 2: 原地假名化 cluster_var ---
    df["cluster_var"] = df["cluster_var"].apply(normalize_value)
    df["cluster_var"] = df["cluster_var"].apply(lambda x: compute_hmac(x, SECRET_KEY))

    # --- Step 3: 删除原始 hospital_id ---
    df = df.drop(columns=["hospital_id"])

    print(f"✅ input2 已完成假名化，共 {len(df)} 条记录")
    return df


# ============================================================
# 执行
# ============================================================

if __name__ == "__main__":
    # ---------- 1. contact_list -> family_id ----------
    df_raw1 = pd.read_stata(INPUT_FILE1)
    print(f"读取 contact_list 完成：{len(df_raw1)} 行")

    df_out1 = anonymize_contact_list(df_raw1)
    df_out1.index = range(1, len(df_out1) + 1)
    df_out1.to_excel(OUTPUT_FILE1)

    print(f"✅ 已保存至 {OUTPUT_FILE1}")
    print(df_out1[["family_id", "lastname", "mother"]].head(10))

    # ---------- 2. anonymized_cluster_data ----------
    df_raw2 = pd.read_stata(INPUT_FILE2)
    print(f"\n读取 anonymized_cluster_data 完成：{len(df_raw2)} 行")

    df_out2 = anonymize_cluster_data(df_raw2)
    df_out2.index = range(1, len(df_out2) + 1)
    df_out2.to_excel(OUTPUT_FILE2)

    print(f"✅ 已保存至 {OUTPUT_FILE2}")
    print(df_out2.head(10))







