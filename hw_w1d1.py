import hashlib
import time

name = "ray"

# 挖前4个0
start = time.time()
n = 0
while True:
    h = hashlib.sha256(f"{name}{n}".encode()).hexdigest()
    if h.startswith("0000"):
        print("前4个0：", name + str(n), h, f"用时 {time.time()-start:.3f}秒")
        break
    n += 1

# 挖前5个0
start = time.time()
n = 0
while True:
    h = hashlib.sha256(f"{name}{n}".encode()).hexdigest()
    if h.startswith("00000"):
        print("前5个0：", name + str(n), h, f"用时 {time.time()-start:.3f}秒")
        break
    n += 1