const express = require("express");
const app = express();
app.get("/", (req, res) => res.send("✅ Niorlusx server is running"));
app.listen(3000, () => console.log("🚀 Listening on port 3000"));
