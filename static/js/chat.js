/**
 * chat.js - 最終イメージ & BDDテスト完全対応版
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
            c.classList.remove('active', 'opacity-100');
            c.classList.add('opacity-60');
        });
        card.classList.add('active', 'opacity-100');
        card.classList.remove('opacity-60');
        
        selectedAgent = card.dataset.agent;
        const name = card.querySelector('.text-sm').textContent;
        currentAgentDisplay.innerHTML = `${name} <span class="text-slate-600 mx-2">|</span> <span class="text-slate-500 font-normal text-xs">Ready</span>`;
    });
});

// 文字数カウント
messageInput.addEventListener('input', () => {
    const len = messageInput.value.length;
    charCountDisplay.textContent = `${len} / 2000`;
    validationErrorDisplay.classList.add('hidden');
});

// テスト要件: sendMessage
async function sendMessage() {
    const message = messageInput.value.trim();
    
    if (message.length === 0) {
        showError("メッセージを入力してください");
        return;
    }

    setLoadingState(true);
    if (initialView) initialView.style.display = 'none';
    messageContainer.classList.remove('hidden');
    
    renderMessage('user', message);
    messageInput.value = '';
    charCountDisplay.textContent = '0 / 2000';

    try {
        const response = await fetch('/api/chat', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ 
                message: message, 
                session_id: currentSessionId,
                agent: selectedAgent // 追加：選択中のエージェントを送る
            })
        });

        if (response.ok) {
            const data = await response.json();
            renderMessage('ai', data.reply);
        } else {
            throw new Error("サーバー応答エラー");
        }
    } catch (err) {
        renderMessage('error', "エラーが発生しました。再試行してください。");
    } finally {
        setLoadingState(false);
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
    sendIcon.classList.toggle('hidden', isLoading);
    loadingSpinner.classList.toggle('hidden', !isLoading);
}

function showError(msg) {
    validationErrorDisplay.textContent = msg;
    validationErrorDisplay.classList.remove('hidden');
}

function renderMessage(role, text) {
    const wrapper = document.createElement('div');
    wrapper.className = role === 'user' ? 'flex justify-end w-full' : 'flex justify-start w-full';
    
    let bubbleClass = "p-4 rounded-2xl max-w-[85%] text-sm leading-relaxed ";
    if (role === 'user') bubbleClass += "bg-emerald-600 text-white shadow-lg shadow-emerald-900/10";
    else if (role === 'error') bubbleClass += "bg-rose-900/30 border border-rose-500/50 text-rose-200";
    else bubbleClass += "frosted text-slate-200";

    wrapper.innerHTML = `<div class="${bubbleClass}">${text}</div>`;
    messageContainer.appendChild(wrapper);
    chatArea.scrollTo({ top: chatArea.scrollHeight, behavior: 'smooth' });
}