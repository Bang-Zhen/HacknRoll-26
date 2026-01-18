import { io, Socket } from "socket.io-client";
import { getApiBase } from "./api-base";

let socket: Socket | null = null;

export function getSocket() {
  if (!socket) {
    const apiBase = getApiBase();
    if (!apiBase) {
      throw new Error(
        "Realtime unavailable on GitHub Pages. Run locally or set NEXT_PUBLIC_API_URL.",
      );
    }
    socket = io(apiBase, {
      withCredentials: true,
    });
  }
  return socket;
}
