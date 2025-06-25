#!/data/data/com.termux/files/usr/bin/bash
# Niorlusx Terminal Control Panel with Hotkey Binding and Ngrok Auto Tunnel

# Ensure dependencies
pkg update -y && pkg install -y nodejs git openssh termux-api

# Set up PM2 and PNPM if not already installed
npm install -g pm2 pnpm

# Export required PNPM paths
export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"

# Make sure shell knows it
echo 'export PNPM_HOME="$HOME/.local/share/pnpm"' >> ~/.bashrc
echo 'export PATH="$PNPM_HOME:$PATH"' >> ~/.bashrc

# Sync .env and service dependencies if not done
cd ~/niorlusx-call-service || exit
pnpm install || npm install

# Ngrok control script (auto run)
cat > ngrok_wrapper.js <<'EOF'
const ngrok = require('ngrok');
(async function () {
  const token = '2ytvAEoCiRT12LLdNmLttIJbP5D_59QRpiE6aLMNbiGquGLSo';
  const port = 3000;
  try {
    await ngrok.authtoken(token);
    const url = await ngrok.connect({ addr: port });
    console.log(`ðŸš€ Ngrok tunnel created at: ${url}`);
  } catch (e) {
    console.error('âŒ Ngrok failed:', e.message);
  }
})();
EOF

# Launch all services
pm2 start server.js --name niorlusx_server
pm2 start ngrok_wrapper.js --interpreter=node --name ngrok
pm2 save

# Display hotkey options
echo "ðŸŽ›ï¸ Hotkeys and Controls:"
echo "[Ctrl+C] Quit"
echo "[F1] Restart server"
echo "[F2] Restart ngrok"
echo "[F3] Show logs"
echo "[F4] Git sync"
echo ""

# Setup hotkey loop
while true; do
  read -rsn1 key
  case $key in
    "") : ;;
    $'') read -rsn2 -t 0.1 key ;; # Ignore escape codes
    $'OP') pm2 restart niorlusx_server ;; # F1
    $'OQ') pm2 restart ngrok ;; # F2
    $'OR') pm2 logs --lines 10 ;; # F3
    $'OS') bash ./sync.sh ;; # F4
  esac
done