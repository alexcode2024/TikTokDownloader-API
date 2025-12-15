# Token 配置说明

## 概述

Web API 接口模式支持 Token 验证，用于保护 API 接口，防止未授权访问。默认情况下，如果未配置 Token，所有请求都可以访问（向后兼容）。

## 配置方式

### 方式一：环境变量（推荐用于生产环境）

#### Linux/Mac 系统

```bash
# 临时设置（当前终端会话有效）
export API_TOKEN="your-secret-token-here"

# 或使用 DOUK_API_TOKEN
export DOUK_API_TOKEN="your-secret-token-here"

# 永久设置（添加到 ~/.bashrc 或 ~/.zshrc）
echo 'export API_TOKEN="your-secret-token-here"' >> ~/.bashrc
source ~/.bashrc
```

#### 在启动脚本中设置

```bash
#!/bin/bash
export API_TOKEN="your-secret-token-here"
cd /home/ubuntu/tiktok/TikTokDownloader
python3 main.py
```

#### 使用 systemd 服务（推荐）

创建服务文件 `/etc/systemd/system/tiktok-downloader.service`：

```ini
[Unit]
Description=TikTok Downloader API Server
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu/tiktok/TikTokDownloader
Environment="API_TOKEN=your-secret-token-here"
ExecStart=/usr/bin/python3 main.py
Restart=always

[Install]
WantedBy=multi-user.target
```

然后启动服务：
```bash
sudo systemctl daemon-reload
sudo systemctl enable tiktok-downloader
sudo systemctl start tiktok-downloader
```

### 方式二：硬编码 Token（适合测试环境）

编辑文件：`src/custom/function.py`

找到 `VALID_TOKENS` 列表，添加你的 token：

```python
VALID_TOKENS = [
    "your-secret-token-1",
    "your-secret-token-2",
    "test-token-12345",
]
```

**注意**：硬编码方式不够安全，不建议用于生产环境。

## 使用 Token

### 测试 Token 是否有效

```bash
curl -H "token: your-secret-token" http://127.0.0.1:5555/token
```

### 调用 API 接口

```bash
# 使用 curl
curl -H "token: your-secret-token" \
     -H "Content-Type: application/json" \
     -X POST \
     -d '{"detail_id": "123456789"}' \
     http://127.0.0.1:5555/douyin/detail
```

### Python 示例

```python
import requests

headers = {
    "token": "your-secret-token",
    "Content-Type": "application/json"
}

data = {
    "detail_id": "123456789"
}

response = requests.post(
    "http://127.0.0.1:5555/douyin/detail",
    json=data,
    headers=headers
)

print(response.json())
```

### JavaScript 示例

```javascript
fetch('http://127.0.0.1:5555/douyin/detail', {
    method: 'POST',
    headers: {
        'token': 'your-secret-token',
        'Content-Type': 'application/json'
    },
    body: JSON.stringify({
        detail_id: '123456789'
    })
})
.then(response => response.json())
.then(data => console.log(data));
```

## 验证逻辑

1. **未配置 Token**：所有请求都可以访问（默认行为）
2. **配置了 Token**：
   - 请求必须提供 `token` 头部
   - Token 必须匹配环境变量或硬编码列表中的值
   - 未提供或 Token 错误将返回 403 错误

## 优先级

1. 环境变量 `API_TOKEN` 或 `DOUK_API_TOKEN`（优先级最高）
2. 硬编码列表 `VALID_TOKENS`

## 安全建议

1. **生产环境**：使用环境变量方式，不要将 Token 硬编码到代码中
2. **Token 强度**：使用足够长且随机的字符串（建议至少 32 个字符）
3. **定期更换**：定期更换 Token，特别是在泄露风险时
4. **HTTPS**：在生产环境中使用 HTTPS 传输，避免 Token 被截获
5. **访问控制**：结合防火墙规则，限制 API 访问来源

## 生成安全 Token

### 使用 Python

```python
import secrets
token = secrets.token_urlsafe(32)
print(token)
```

### 使用 OpenSSL

```bash
openssl rand -hex 32
```

### 使用 /dev/urandom

```bash
cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1
```

## 故障排查

### Token 验证失败

1. 检查环境变量是否正确设置：
   ```bash
   echo $API_TOKEN
   ```

2. 检查硬编码列表是否正确配置

3. 确认请求头名称是 `token`（小写）

4. 查看 API 文档：访问 `http://127.0.0.1:5555/docs` 查看接口说明

### 测试 Token

```bash
# 测试 token 端点
curl -H "token: your-token" http://127.0.0.1:5555/token

# 如果返回 {"message": "验证成功！"} 说明 token 有效
```

## 注意事项

- Token 验证仅对 Web API 模式生效
- 终端交互模式不需要 Token
- 如果未配置任何 Token，API 默认允许所有请求（向后兼容）
- Token 区分大小写


1. 先启动虚拟环境source venv/bin/activate
2. 启动api模式：python3 main.py api