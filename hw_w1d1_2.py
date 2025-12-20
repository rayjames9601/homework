import hashlib
import time

from cryptography.hazmat.primitives.asymmetric import ed25519
from cryptography.hazmat.primitives import serialization

name = "ray"


def mine(prefix: str):
    """寻找满足哈希前缀的 nonce。"""
start = time.time()
n = 0
while True:
        msg = f"{name}{n}".encode()
        h = hashlib.sha256(msg).hexdigest()
        if h.startswith(prefix):
            duration = time.time() - start
            return n, h, duration
        n += 1


# 生成公私钥
private_key = ed25519.Ed25519PrivateKey.generate()
public_key = private_key.public_key()

# 挖到前 4 个 0
nonce, hash4, duration = mine("0000")
message = f"{name}{nonce}".encode()
signature = private_key.sign(message)

# 用公钥验证签名
try:
    public_key.verify(signature, message)
    verified = True
except Exception:
    verified = False

# 打印结果
pub_bytes = public_key.public_bytes(
    encoding=serialization.Encoding.Raw,
    format=serialization.PublicFormat.Raw,
).hex()
priv_bytes = private_key.private_bytes(
    encoding=serialization.Encoding.Raw,
    format=serialization.PrivateFormat.Raw,
    encryption_algorithm=serialization.NoEncryption(),
).hex()

print("私钥（Hex）:", priv_bytes)
print("公钥（Hex）:", pub_bytes)
print("前4个0：", name + str(nonce), hash4, f"用时 {duration:.3f}秒")
print("签名（Hex）:", signature.hex())
print("验证通过:", verified)