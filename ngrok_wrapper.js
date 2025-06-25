const ngrok = require('ngrok');

(async function () {
  const token = '2ytvAEoCiRT12LLdNmLttIJbP5D_59QRpiE6aLMNbiGquGLSo';
  const port = 3000;

  try {
    await ngrok.authtoken(token);
    const url = await ngrok.connect({ addr: port });
    console.log(`🚀 Ngrok tunnel created at: ${url}`);
  } catch (e) {
    console.error('❌ Ngrok failed:', e.message);
  }
})();
