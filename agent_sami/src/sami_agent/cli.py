from __future__ import annotations

import argparse
import asyncio
import contextlib
import signal

from .agent import SamiAgent
from .config import load_config


def main() -> None:
  parser = argparse.ArgumentParser(description='SAMI Edge Agent')
  parser.add_argument('--config', default='/etc/sami/config.yaml')
  args = parser.parse_args()

  config = load_config(args.config)
  agent = SamiAgent(config)

  loop = asyncio.new_event_loop()
  asyncio.set_event_loop(loop)

  def _handle_stop(*_: int) -> None:
    loop.create_task(agent.stop())

  loop.add_signal_handler(signal.SIGTERM, _handle_stop)
  loop.add_signal_handler(signal.SIGINT, _handle_stop)

  async def runner() -> None:
    try:
      await agent.run()
    finally:
      await agent.stop()

  import contextlib

  loop.run_until_complete(runner())


if __name__ == '__main__':
  main()
