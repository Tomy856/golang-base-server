/**
 * chat.js - Agent Chat Logic
 * BDDテスト(03-06)対応版
 */

// セッションIDの生成 (Test要件: generateUUID)
function generateUUID() {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
        var r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
        return v.toString(16);
    });
}

const currentSessionId = generateUUID();

// 要素の取得
const messageInput = document.getElementById('message');
const sendButton = document.getElementById('send');
const sendIcon = document.getElementById('sendIcon');
const loadingSpinner = document.getElementById('loadingSpinner');
const charCountDisplay = document.getElementById('charCount');
const validationErrorDisplay = document.getElementById('validationError');
const messageContainer = document.getElementById('messageContainer');
const chatArea = document.getElementById('chat');
const initialView = document.getElementById('initialView');

// 文字数カウントの更新
messageInput.addEventListener('input', () => {
    const len = messageInput.value.length;
    charCountDisplay.textContent = `${len} / 2000`;
    validationErrorDisplay.classList.add('hidden');
});

// メッセージ送信処理 (Test要件: sendMessage)
async function sendMessage() {
    const message = messageInput.value.trim();
    
    // バリデーション (Feature 04)
    if (message.length === 0) {
        showError("1文字以上入力してください");
        return;
    }

    setLoadingState(true);
    if (initialView) initialView.classList.add('hidden');
    messageContainer.classList.remove('hidden');
    
    renderMessage('user', message);
    
    const originalText = messageInput.value;
    messageInput.value = '';
    charCountDisplay.textContent = '0 / 2000';

    // タイムアウト設定 (Feature 06: 30s)
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), 30000);

    try {
        const response = await fetch('/api/chat', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ 
                message: message, 
                session_id: currentSessionId 
            }),
            signal: controller.signal
        });

        clearTimeout(timeout);

        if (response.ok) {
            const data = await response.json();
            renderMessage('ai', data.reply);
            messageInput.focus();
        } else {
            // サーバーエラー (Feature 05)
            const errorText = (response.status === 500 || response.status === 503)
                ? "一時的にAIが応答できません。時間を置いて再度お試しください"
                : "サーバーエラーが発生しました";
            throw new Error(errorText);
        }
    } catch (err) {
        const displayErr = err.name === 'AbortError' 
            ? "応答がタイムアウトしました。再度お試しください" 
            : err.message;
        renderMessage('error', displayErr);
        messageInput.value = originalText; // 入力保持 (Feature 05/06)
    } finally {
        setLoadingState(false);
    }
}

// イベントリスナー
sendButton.addEventListener('click', sendMessage);
messageInput.addEventListener('keydown', (e) => {
    if (e.key === 'Enter' && !e.shiftKey) {
        e.preventDefault();
        sendMessage();
    }
});

function setLoadingState(isLoading) {
    sendButton.disabled = isLoading;
    sendIcon.classList.toggle('hidden', isLoading);
    loadingSpinner.classList.toggle('hidden', !isLoading);
}

function showError(msg) {
    validationErrorDisplay.textContent = msg;
    validationErrorDisplay.classList.remove('hidden');
}

function renderMessage(role, text) {
    const wrapper = document.createElement('div');
    wrapper.className = role === 'user' ? 'flex justify-end' : 'flex justify-start';
    
    let bubbleClass = "p-4 rounded-2xl max-w-[80%] shadow-lg ";
    if (role === 'user') bubbleClass += "bg-emerald-600 text-white";
    else if (role === 'error') bubbleClass += "bg-rose-900/50 border border-rose-500 text-rose-100";
    else bubbleClass += "frosted text-slate-200";

    wrapper.innerHTML = `<div class="${bubbleClass}">${text}</div>`;
    messageContainer.appendChild(wrapper);
    chatArea.scrollTo({ top: chatArea.scrollHeight, behavior: 'smooth' });
}