import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.0"

console.log("Delete User Function Initialized")

serve(async (req: Request) => {
    // Handle CORS preflight requests
    if (req.method === 'OPTIONS') {
        return new Response('ok', {
            headers: {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
            },
        })
    }

    try {
        // 1. Create Supabase Client with Service Role Key
        // This is required to delete users from auth.users which is restricted
        const supabaseUrl = Deno.env.get('SUPABASE_URL')
        const supabaseServiceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')

        if (!supabaseUrl || !supabaseServiceRoleKey) {
            throw new Error('Server configuration error: Supabase keys not set')
        }

        const supabaseAdmin = createClient(supabaseUrl, supabaseServiceRoleKey)

        // 2. Parse request body
        const { userId } = await req.json()

        if (!userId) {
            throw new Error('User ID is required')
        }

        // 3. Verify the caller is an authenticated admin (Optional but recommended)
        // For now, we assume the RLS on the functions invocation handles basic auth, 
        // but checking admin role explicitly is safer.
        const authHeader = req.headers.get('Authorization')
        if (!authHeader) {
            throw new Error('Missing Authorization header')
        }

        // Get the user from the auth token
        const token = authHeader.replace('Bearer ', '')
        const { data: { user: caller }, error: authError } = await supabaseAdmin.auth.getUser(token)

        if (authError || !caller) {
            throw new Error('Unauthorized caller')
        }

        // Check if caller is admin
        const { data: profile, error: profileError } = await supabaseAdmin
            .from('profiles')
            .select('is_admin')
            .eq('id', caller.id)
            .single()

        if (profileError || !profile || !profile.is_admin) {
            throw new Error('Forbidden: Only admins can delete users')
        }

        console.log(`Admin ${caller.id} requesting deletion of user ${userId}`)

        // 4. Delete user data (Order matters for foreign keys if no cascading)
        // Note: Using Service Role bypasses RLS

        // Delete credit transactions
        await supabaseAdmin.from('credit_transactions').delete().eq('user_id', userId)

        // Delete CVs
        await supabaseAdmin.from('cvs').delete().eq('user_id', userId)

        // Delete cover letters
        await supabaseAdmin.from('cover_letters').delete().eq('user_id', userId)

        // Delete profile
        await supabaseAdmin.from('profiles').delete().eq('id', userId)

        // 5. Delete from Auth (The critical part)
        const { error: deleteError } = await supabaseAdmin.auth.admin.deleteUser(
            userId
        )

        if (deleteError) {
            throw new Error(`Failed to delete auth user: ${deleteError.message}`)
        }

        console.log(`Successfully deleted user ${userId}`)

        return new Response(
            JSON.stringify({ success: true, message: 'User deleted successfully' }),
            {
                headers: {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*',
                },
                status: 200,
            }
        )

    } catch (error) {
        console.error('Error deleting user:', error)
        const errorMessage = error instanceof Error ? error.message : 'Unknown error'

        return new Response(
            JSON.stringify({ error: errorMessage }),
            {
                headers: {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*',
                },
                status: 400,
            }
        )
    }
})
