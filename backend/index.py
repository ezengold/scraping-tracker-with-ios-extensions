import requests
import time
import asyncio
from websockets.server import serve, WebSocketServerProtocol
from bs4 import BeautifulSoup
import json


class TrackerApp:
    """
    Documentation goes here
    """

    WSS_HOST = "127.0.0.1"

    WSS_PORT = 5173

    SITE_URL = "https://www.timeanddate.com/worldclock/timezone/utc"
    # SITE_URL = "https://www.fnac.com/Console-Sony-PS5-Slim-Edition-Digital-Blanc-et-Noir/a18919799/w-4"

    def __init__(self):
        None

    async def start(self):
        async with serve(self.handler, self.WSS_HOST, self.WSS_PORT):
            await asyncio.Future()

    async def handler(self, websocket: WebSocketServerProtocol):
        while True:
            time.sleep(5)
            try:
                response = requests.get(self.SITE_URL, headers={
                    # "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36",
                    # "Accept": "/"
                })

                if response.status_code == 200:
                    # parse data
                    soup = BeautifulSoup(response.content, "html.parser")
                    span_content = soup.find("span", {"id": "ct"})
                    # span_content = soup.find(
                    #     "span", class_="userPrice"
                    # )

                    # send data
                    print(span_content.string)
                    await websocket.send(json.dumps({"value": span_content.string}))

                else:
                    print(response.content)
                    print(
                        "Failed to retrieve the webpage, status code:",
                        response.status_code,
                    )

            except Exception as e:
                print(e)


app = TrackerApp()

asyncio.run(app.start())
