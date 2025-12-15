import sys
from asyncio import CancelledError
from asyncio import run

from src.application import TikTokDownloader


async def main():
    # 检查命令行参数
    mode = sys.argv[1] if len(sys.argv) > 1 else None
    
    async with TikTokDownloader() as downloader:
        try:
            if mode == "api":
                # 直接启动 API 模式
                await downloader.run_api_mode()
            else:
                # 正常显示 UI 菜单
                await downloader.run()
        except (
                KeyboardInterrupt,
                CancelledError,
        ):
            return


if __name__ == "__main__":
    run(main())
