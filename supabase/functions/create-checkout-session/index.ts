import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
// @ts-ignore
import Stripe from 'https://esm.sh/stripe@12.18.0?target=deno'

console.log("Create Checkout Session Function Initialized")

serve(async (req) => {
    // Handle CORS preflight requests
    // This is necessary because the browser initiates the request from a different domain
    if (req.method === 'OPTIONS') {
        return new Response('ok', {
            headers: {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
            },
        })
    }

    try {
        // 1. Get the Stripe Secret Key from environment variables
        // This MUST be set in your Supabase project dashboard
        const stripeKey = Deno.env.get('STRIPE_SECRET_KEY')
        if (!stripeKey) {
            console.error('STRIPE_SECRET_KEY is not set')
            throw new Error('Server configuration error: Stripe key not set')
        }

        // Initialize Stripe
        const stripe = new Stripe(stripeKey, {
            apiVersion: '2023-10-16',
            httpClient: Stripe.createFetchHttpClient(),
        })

        // 2. Parse the request body
        const { userId, userEmail, credits = 25, amount = 5.00 } = await req.json()

        console.log(`Creating session for user: ${userId}, email: ${userEmail}, credits: ${credits}`)

        // 3. Create the Stripe Checkout Session
        // We pass the userId in metadata so we can fulfill the order later via webhook (optional but recommended)
        const session = await stripe.checkout.sessions.create({
            payment_method_types: ['card'],
            line_items: [
                {
                    price_data: {
                        currency: 'usd',
                        product_data: {
                            name: `${credits} Credits Pack`,
                            description: 'Credits for CV optimization and tailoring',
                            images: ['https://cvmanagerai.com/assets/icon/app_icon.png'], // Update with your actual logo URL if available
                        },
                        unit_amount: Math.round(amount * 100), // Amount in cents (500 = $5.00)
                    },
                    quantity: 1,
                },
            ],
            mode: 'payment',
            success_url: 'https://cvmanagerai.com/app/#/?payment=success',
            cancel_url: 'https://cvmanagerai.com/app/#/?payment=cancel',
            customer_email: userEmail,
            metadata: {
                userId: userId,
                credits: credits.toString(),
                type: 'credit_purchase',
            },
        })

        console.log('Session created successfully:', session.id)

        // 4. Return the session data (including url) to the client
        return new Response(
            JSON.stringify(session),
            {
                headers: {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*', // Allow all origins (or restrict to your specific domain)
                },
                status: 200,
            }
        )

    } catch (error) {
        console.error('Error creating checkout session:', error)

        return new Response(
            JSON.stringify({ error: error.message }),
            {
                headers: {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*',
                },
                status: 400, // Return 400 for bad requests or internal errors
            }
        )
    }
})
