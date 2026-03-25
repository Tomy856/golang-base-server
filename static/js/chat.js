// chat.js - AI Chat Interface

document.addEventListener('DOMContentLoaded', function() {
    const chat = document.getElementById('chat');
    const messageInput = document.getElementById('message');
    const sendButton = document.getElementById('send');
    const errorDiv = document.getElementById('error');

    // Generate a simple UUID for session_id (not cryptographically secure, but sufficient for demo)
    function generateUUID() {
        return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
            const r = Math.random() * 16 | 0;
            const v = c === 'x' ? r : (r & 0x3 | 0x8);
            return v.toString(16);
        });
    }

    const sessionID = generateUUID();

    sendButton.addEventListener('click', sendMessage);
    messageInput.addEventListener('keypress', function(e) {
        if (e.key === 'Enter') {
            sendMessage();
        }
    });

    function sendMessage() {
        const message = messageInput.value.trim();
        if (!validateMessage(message)) {
            return;
        }

        // Disable send button
        sendButton.disabled = true;

        // Add user message to chat
        addMessage('You', message);
        messageInput.value = '';

        // Send to API
        fetch('/api/chat', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                message: message,
                session_id: sessionID
            })
        })
        .then(response => response.json())
        .then(data => {
            if (data.status === 'success') {
                addMessage('AI', data.reply);
                clearError();
            } else {
                showError(data.error_message || 'Unknown error');
            }
        })
        .catch(error => {
            showError('Network error or timeout');
            console.error('Error:', error);
        })
        .finally(() => {
            sendButton.disabled = false;
        });
    }

    function validateMessage(message) {
        if (message.length === 0) {
            showError('メッセージを入力してください');
            return false;
        }
        if (message.length > 2000) {
            showError('メッセージは2000文字以内で入力してください');
            return false;
        }
        clearError();
        return true;
    }

    function addMessage(sender, text) {
        const messageDiv = document.createElement('div');
        messageDiv.innerHTML = `<strong>${sender}:</strong> ${text}`;
        chat.appendChild(messageDiv);
        chat.scrollTop = chat.scrollHeight;
    }

    function showError(message) {
        errorDiv.textContent = message;
    }

    function clearError() {
        errorDiv.textContent = '';
    }
});