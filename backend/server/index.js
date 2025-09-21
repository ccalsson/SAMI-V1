const express = require('express');
const axios = require('axios');
const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

app.post('/chat', async (req, res) => {
    const { message, userContext } = req.body;
    try {
        const response = await axios.post('https://api.openai.com/v1/chat/completions', {
            model: "gpt-4",
            messages: [
                {
                    role: "system",
                    content: `You are a mental health assistant. User context: ${userContext}`
                },
                {
                    role: "user",
                    content: message
                }
            ],
            max_tokens: 150
        }, {
            headers: {
                'Authorization': `Bearer ${process.env.OPENAI_API_KEY}`,
                'Content-Type': 'application/json'
            }
        });
        
        res.json({ 
            reply: response.data.choices[0].message.content,
            sentiment: analyzeSentiment(message)
        });
    } catch (error) {
        console.error('Error:', error);
        res.status(500).send('Error communicating with AI');
    }
});

function analyzeSentiment(message) {
    // Implementar análisis de sentimientos
    return "neutral";
}

app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
}); 