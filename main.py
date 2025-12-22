# -*- coding: utf-8 -*-
import sys
from asyncio import CancelledError
from asyncio import run

from src.application import TikTokDownloader

async def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else None
    async with TikTokDownloader() as downloader:
        try:
            if mode == "api":
                await downloader.run_api_mode()
            else:
                await downloader.run()
        except (
                KeyboardInterrupt,
                CancelledError,
        ):
            return

if __name__ == "__main__":
    run(main())
