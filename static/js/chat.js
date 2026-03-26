/**
 * chat.js - BDD 02-01-chat-display-fix.feature 対応版
 * Tailwind CDN 非依存: メッセージバブルをインラインスタイルで描画
 */

// テスト要件: generateUUID
function generateUUID() {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
        var r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
        return v.toString(16);
    });
}

const currentSessionId = generateUUID();
let selectedAgent = 'work'; // デフォルト

// 要素取得
const messageInput = document.getElementById('message');
const sendButton = document.getElementById('send');
const sendIcon = document.getElementById('sendIcon');
const loadingSpinner = document.getElementById('loadingSpinner');
const charCountDisplay = document.getElementById('charCount');
const validationErrorDisplay = document.getElementById('validationError');
const messageContainer = document.getElementById('messageContainer');
const chatArea = document.getElementById('chat');
const initialView = document.getElementById('initialView');
const agentCards = document.querySelectorAll('.agent-card');
const currentAgentDisplay = document.getElementById('currentAgentDisplay');

// エージェント切り替えロジック
agentCards.forEach(card => {
    card.addEventListener('click', () => {
        agentCards.forEach(c => {
            c.classList.remove('active');
            c.style.opacity = '0.5';
        });
        card.classList.add('active');
        card.style.opacity = '1';

        selectedAgent = card.dataset.agent;
        const nameEl = card.querySelector('div > div:first-child');
        const name = nameEl ? nameEl.textContent : selectedAgent;
        currentAgentDisplay.innerHTML = `${name} <span style="margin: 0 12px; color: #334155;">|</span> <span style="font-size: 12px; color: #64748b;">Ready</span>`;
    });
});

// 文字数カウント
messageInput.addEventListener('input', () => {
    const len = messageInput.value.length;
    charCountDisplay.textContent = `${len} / 2000`;
    validationErrorDisplay.style.display = 'none';
});

// テスト要件: sendMessage
async function sendMessage() {
    const message = messageInput.value.trim();

    if (message.length === 0) {
        showError("メッセージを入力してください");
        return;
    }

    // initialView を非表示にしてチャットエリアを表示
    if (initialView) initialView.style.display = 'none';
    messageContainer.style.display = 'block';

    setLoadingState(true);
    renderMessage('user', message);
    messageInput.value = '';
    charCountDisplay.textContent = '0 / 2000';

    try {
        const controller = new AbortController();
        const timeoutId = setTimeout(() => controller.abort(), 30000);

        const response = await fetch('/api/chat', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                message: message,
                session_id: currentSessionId,
                agent: selectedAgent
            }),
            signal: controller.signal
        });

        clearTimeout(timeoutId);

        if (response.ok) {
            const data = await response.json();
            renderMessage('ai', data.reply);
        } else {
            renderMessage('error', "一時的にAIが応答できません。時間を置いて再度お試しください。");
        }
    } catch (err) {
        if (err.name === 'AbortError') {
            renderMessage('error', "応答がタイムアウトしました。再送信してください。");
        } else {
            renderMessage('error', "エラーが発生しました。再試行してください。");
        }
    } finally {
        setLoadingState(false);
        messageInput.focus();
    }
}

sendButton.addEventListener('click', sendMessage);
messageInput.addEventListener('keydown', (e) => {
    if (e.key === 'Enter' && !e.shiftKey) {
        e.preventDefault();
        sendMessage();
    }
});

function setLoadingState(isLoading) {
    sendButton.disabled = isLoading;
    sendIcon.style.display = isLoading ? 'none' : 'flex';
    loadingSpinner.style.display = isLoading ? 'block' : 'none';
}

function showError(msg) {
    validationErrorDisplay.textContent = msg;
    validationErrorDisplay.style.display = 'block';
}

/**
 * renderMessage - メッセージバブルを描画する
 * Tailwind CDN 非依存: インラインスタイルで描画
 * @param {string} role - 'user' | 'ai' | 'error'
 * @param {string} text - 表示するテキスト
 */
function renderMessage(role, text) {
    const wrapper = document.createElement('div');
    wrapper.style.cssText = 'display:flex; width:100%; margin-bottom:16px;';

    const bubble = document.createElement('div');
    bubble.style.cssText = 'max-width:85%; padding:14px 18px; border-radius:18px; font-size:14px; line-height:1.6; word-break:break-word;';

    if (role === 'user') {
        wrapper.style.justifyContent = 'flex-end';
        bubble.style.backgroundColor = '#10b981';
        bubble.style.color = '#ffffff';
    } else if (role === 'error') {
        wrapper.style.justifyContent = 'flex-start';
        bubble.style.backgroundColor = 'rgba(153,27,27,0.3)';
        bubble.style.border = '1px solid rgba(239,68,68,0.5)';
        bubble.style.color = '#fca5a5';
    } else {
        // ai
        wrapper.style.justifyContent = 'flex-start';
        bubble.style.backgroundColor = 'rgba(255,255,255,0.05)';
        bubble.style.border = '1px solid rgba(255,255,255,0.08)';
        bubble.style.color = '#e2e8f0';
    }

    bubble.textContent = text;
    wrapper.appendChild(bubble);
    messageContainer.appendChild(wrapper);
    chatArea.scrollTo({ top: chatArea.scrollHeight, behavior: 'smooth' });
}
