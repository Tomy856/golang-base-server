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
 */
async function callGemini(message) {
  const axios = require('axios');
  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey) throw new Error('GEMINI_API_KEY is not set');

  const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=${apiKey}`;
  const body = {
    contents: [{ parts: [{ text: message }] }]
  };

  const response = await axios.post(url, body);
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
