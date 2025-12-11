# Deploy DeepSeek Proxy Edge Function to Supabase

This guide will help you deploy the `deepseek-proxy` Edge Function to your Supabase project.

## Prerequisites

- Node.js and npm installed
- Access to your Supabase project dashboard
- DeepSeek API key (`sk-83b55daba1084007abb1d903633a742f`)

## Step 1: Install Supabase CLI

Open PowerShell and run:

```powershell
npm install -g supabase
```

Verify installation:

```powershell
supabase --version
```

## Step 2: Login to Supabase

```powershell
supabase login
```

This will open a browser window for you to authenticate with your Supabase account.

## Step 3: Link Your Project

Navigate to your project directory:

```powershell
cd "c:\Users\Lenovo\OneDrive\Desktop\CV APP with antigravity\flutter_cv_app"
```

Link to your Supabase project:

```powershell
supabase link --project-ref gjyikixqeqklbdjakmqu
```

When prompted for the database password, enter your Supabase database password.

## Step 4: Set Environment Secret

Set your DeepSeek API key as a secret (this keeps it secure and hidden from your code):

```powershell
supabase secrets set DEEPSEEK_API_KEY=sk-83b55daba1084007abb1d903633a742f
```

## Step 5: Deploy the Edge Function

Deploy the `deepseek-proxy` function:

```powershell
supabase functions deploy deepseek-proxy
```

## Step 6: Get Your Edge Function URL

After deployment, your Edge Function URL will be:

```
https://gjyikixqeqklbdjakmqu.supabase.co/functions/v1/deepseek-proxy
```

You'll need to add this URL to your Flutter app's `app_constants.dart` file.

## Step 7: Test the Edge Function

You can test the Edge Function using curl or Postman:

```powershell
curl -X POST https://gjyikixqeqklbdjakmqu.supabase.co/functions/v1/deepseek-proxy `
  -H "Content-Type: application/json" `
  -H "Authorization: Bearer YOUR_SUPABASE_ANON_KEY" `
  -d '{\"prompt\": \"Hello, how are you?\", \"systemMessage\": \"You are a helpful assistant.\"}'
```

Replace `YOUR_SUPABASE_ANON_KEY` with your Supabase anon key from `app_constants.dart`.

## Troubleshooting

### If deployment fails:

1. **Check Supabase CLI version**: Ensure you have the latest version
   ```powershell
   npm install -g supabase@latest
   ```

2. **Verify project link**: 
   ```powershell
   supabase projects list
   ```

3. **Check logs**:
   ```powershell
   supabase functions logs deepseek-proxy
   ```

### If the function returns errors:

1. **Verify secret is set**:
   ```powershell
   supabase secrets list
   ```
   You should see `DEEPSEEK_API_KEY` in the list.

2. **Check function logs**:
   ```powershell
   supabase functions logs deepseek-proxy --tail
   ```

## Next Steps

After successful deployment:
1. Update `app_constants.dart` with the Edge Function URL
2. Update `cv_controller.dart` and `cover_letter_controller.dart` to use the Edge Function
3. Test all AI features on the web app

## Updating the Edge Function

If you need to make changes to the Edge Function code:

1. Edit `supabase/functions/deepseek-proxy/index.ts`
2. Redeploy:
   ```powershell
   supabase functions deploy deepseek-proxy
   ```

## Viewing Logs

To monitor your Edge Function in real-time:

```powershell
supabase functions logs deepseek-proxy --tail
```
