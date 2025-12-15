#!/usr/bin/env python3
"""
测试 Token 验证功能
"""
from src.custom.function import is_valid_token, VALID_TOKENS
from os import getenv

def test_token_validation():
    print("=" * 60)
    print("Token 验证功能测试")
    print("=" * 60)
    print()
    
    print(f"✅ VALID_TOKENS 配置: {VALID_TOKENS}")
    print(f"✅ 环境变量 API_TOKEN: {getenv('API_TOKEN', '未设置')}")
    print(f"✅ 环境变量 DOUK_API_TOKEN: {getenv('DOUK_API_TOKEN', '未设置')}")
    print()
    
    # 检查是否配置了 token
    env_token = getenv("API_TOKEN") or getenv("DOUK_API_TOKEN")
    has_config = bool(env_token or VALID_TOKENS)
    
    if not has_config:
        print("⚠️  警告：未配置任何 Token，所有请求都可以访问（默认行为）")
        print("   建议配置 Token 以保护 API 接口")
    else:
        print("✅ Token 验证已启用")
    print()
    
    # 测试用例
    test_cases = [
        (None, "未提供 token (None)"),
        ("", "空字符串"),
        ("your-secret-token-1", "有效 token 1"),
        ("your-secret-token-2", "有效 token 2"),
        ("test-token-12345", "有效 token 3"),
        ("invalid-token", "无效 token"),
    ]
    
    print("测试结果：")
    print("-" * 60)
    for token, desc in test_cases:
        result = is_valid_token(token)
        status = "✅ 通过" if result else "❌ 拒绝"
        token_display = token if token else "(无)"
        print(f"{desc:25} | Token: {token_display:25} | {status}")
    print("-" * 60)
    print()
    
    # 使用建议
    print("使用示例：")
    print("  curl -H 'token: your-secret-token-1' http://127.0.0.1:5555/token")
    print()
    
    if has_config:
        print("✅ Token 验证功能已正确配置并启用！")
    else:
        print("⚠️  请配置 Token 以启用验证功能")

if __name__ == "__main__":
    test_token_validation()

