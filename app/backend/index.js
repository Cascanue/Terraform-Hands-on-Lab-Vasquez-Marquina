const http = require("http");
const net  = require("net");

const PORT    = 3000;
const APP_ENV = process.env.APP_ENV || "local";
const DB_HOST = process.env.DB_HOST || "localhost";
const DB_PORT = Number(process.env.DB_PORT) || 5432;

const headers = {
  "Content-Type": "application/json",
  "Access-Control-Allow-Origin": "*"
};

http.createServer((req, res) => {

  if (req.url === "/" && req.method === "GET") {
    res.writeHead(200, headers);
    res.end(JSON.stringify({
      servicio: "api",
      ambiente: APP_ENV,
      instancia: process.env.HOSTNAME
    }));
    return;
  }

  if (req.url === "/db" && req.method === "GET") {
    const socket = net.createConnection({ host: DB_HOST, port: DB_PORT });
    socket.setTimeout(2000);

    socket.on("connect", () => {
      res.writeHead(200, headers);
      res.end(JSON.stringify({ bd: "conectado", host: DB_HOST }));
      socket.destroy();
    });

    const fail = (err) => {
      res.writeHead(503, headers);
      res.end(JSON.stringify({ bd: "sin conexion", error: err.message }));
      socket.destroy();
    };

    socket.on("error",   fail);
    socket.on("timeout", () => fail(new Error("timeout")));
    return;
  }

  res.writeHead(404, headers);
  res.end(JSON.stringify({ error: "ruta no encontrada" }));

}).listen(PORT, () => console.log(`api corriendo en puerto ${PORT}`));
