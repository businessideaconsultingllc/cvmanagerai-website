import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const DEEPSEEK_API_URL = "https://api.deepseek.com/v1/chat/completions";
const DEEPSEEK_API_KEY = Deno.env.get('DEEPSEEK_API_KEY');

serve(async (req) => {
    // Handle CORS preflight
    if (req.method === 'OPTIONS') {
        return new Response(null, {
            headers: {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Methods': 'POST, OPTIONS',
                'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
            },
        });
    }

    try {
        // Validate method
        if (req.method !== 'POST') {
            return new Response(
                JSON.stringify({ error: 'Method not allowed' }),
                {
                    status: 405,
                    headers: {
                        'Content-Type': 'application/json',
                        'Access-Control-Allow-Origin': '*'
                    }
                }
            );
        }

        // Check API key is configured
        if (!DEEPSEEK_API_KEY) {
            console.error('DEEPSEEK_API_KEY is not configured');
            return new Response(
                JSON.stringify({ error: 'Server configuration error' }),
                {
                    status: 500,
                    headers: {
                        'Content-Type': 'application/json',
                        'Access-Control-Allow-Origin': '*'
                    }
                }
            );
        }

        // Parse request body
        const { prompt, systemMessage } = await req.json();

        if (!prompt) {
            return new Response(
                JSON.stringify({ error: 'Prompt is required' }),
                {
                    status: 400,
                    headers: {
                        'Content-Type': 'application/json',
                        'Access-Control-Allow-Origin': '*'
                    }
                }
            );
        }

        // Call DeepSeek API
        const deepseekResponse = await fetch(DEEPSEEK_API_URL, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${DEEPSEEK_API_KEY}`,
            },
            body: JSON.stringify({
                model: 'deepseek-chat',
                messages: [
                    {
                        role: 'system',
                        content: systemMessage || 'You are a helpful assistant.'
                    },
                    {
                        role: 'user',
                        content: prompt
                    },
                ],
                temperature: 0.7,
            }),
        });

        // Handle DeepSeek API errors
        if (!deepseekResponse.ok) {
            const errorText = await deepseekResponse.text();
            console.error('DeepSeek API error:', errorText);
            return new Response(
                JSON.stringify({
                    error: 'DeepSeek API error',
                    details: errorText
                }),
                {
                    status: deepseekResponse.status,
                    headers: {
                        'Content-Type': 'application/json',
                        'Access-Control-Allow-Origin': '*'
                    }
                }
            );
        }

        // Parse and return response
        const data = await deepseekResponse.json();
        const content = data.choices?.[0]?.message?.content;

        if (!content) {
            console.error('Unexpected response format:', data);
            return new Response(
                JSON.stringify({ error: 'Unexpected response format from DeepSeek' }),
                {
                    status: 500,
                    headers: {
                        'Content-Type': 'application/json',
                        'Access-Control-Allow-Origin': '*'
                    }
                }
            );
        }

        return new Response(
            JSON.stringify({ content }),
            {
                status: 200,
                headers: {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                }
            }
        );

    } catch (error) {
        console.error('Edge Function error:', error);
        return new Response(
            JSON.stringify({
                error: 'Internal server error',
                message: error.message
            }),
            {
                status: 500,
                headers: {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                }
            }
        );
    }
})
