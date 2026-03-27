// NODE_PATH=/node_modules で依存パッケージを解決
require('dotenv').config();
const express = require('express');
const app = express();

app.use(express.json());

const PORT = process.env.PORT || 3000;
const AI_PROVIDER = process.env.AI_PROVIDER || 'mock'; // 'mock' | 'gemini' | 'bedrock'

/**
 * POST /proxy/chat
 * Body: { message: string, session_id: string, agent?: string }
 * Response: { reply: string }
 */
app.post('/proxy/chat', async (req, res) => {
  const { message, session_id, agent } = req.body;

  if (!message || !session_id) {
    return res.status(400).json({ error: 'message and session_id are required' });
  }

  try {
    const reply = await getAIReply(message, session_id, agent);
    res.json({ reply });
  } catch (err) {
    console.error('[AI Error]', err.message);
    res.status(500).json({ error: 'AI processing failed', detail: err.message });
  }
});

/**
 * AIプロバイダーに応じてレスポンスを返す
 * AI_PROVIDER 環境変数で切り替え: mock / gemini / bedrock
 */
async function getAIReply(message, sessionId, agent) {
  switch (AI_PROVIDER) {
    case 'gemini':
      return await callGemini(message);
    case 'bedrock':
      return await callBedrock(message);
    case 'mock':
    default:
      return `[Mock] あなたのメッセージ: "${message}" を受け取りました。(agent: ${agent || 'default'})`;
  }
}

/**
 * Gemini API呼び出し（実装例）
 * 環境変数: GEMINI_API_KEY
 * 社内プロキシ環境: HTTPS_PROXY または https_proxy を自動参照
 */
async function callGemini(message) {
  const axios = require('axios');
  const { HttpsProxyAgent } = require('https-proxy-agent');

  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey) throw new Error('GEMINI_API_KEY is not set');

  const url = `https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent?key=${apiKey}`;
  const body = {
    contents: [{ parts: [{ text: message }] }]
  };

  // 社内プロキシ対応: 環境変数 HTTPS_PROXY / https_proxy を参照
  const proxyUrl = process.env.HTTPS_PROXY || process.env.https_proxy || null;
  const axiosConfig = {};
  if (proxyUrl) {
    axiosConfig.httpsAgent = new HttpsProxyAgent(proxyUrl);
    axiosConfig.proxy = false; // axiosのデフォルトプロキシ処理を無効化してagentに委譲
  }

  const response = await axios.post(url, body, axiosConfig);
  const text = response.data?.candidates?.[0]?.content?.parts?.[0]?.text;
  if (!text) throw new Error('Gemini returned empty response');
  return text;
}

/**
 * AWS Bedrock呼び出し（実装例）
 * 環境変数: AWS_REGION, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY
 * 注: @aws-sdk/client-bedrock-runtime を別途インストールが必要
 */
async function callBedrock(message) {
  // TODO: @aws-sdk/client-bedrock-runtime を使って実装
  // const { BedrockRuntimeClient, InvokeModelCommand } = require('@aws-sdk/client-bedrock-runtime');
  throw new Error('Bedrock integration is not yet implemented. Set AI_PROVIDER=mock or gemini.');
}

app.listen(PORT, () => {
  console.log(`[node-proxy] AI proxy server running on port ${PORT} (provider: ${AI_PROVIDER})`);
});
