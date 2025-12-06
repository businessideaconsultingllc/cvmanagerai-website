class AppConstants {
  static const String supabaseUrl = 'https://gjyikixqeqklbdjakmqu.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdqeWlraXhxZXFrbGJkamFrbXF1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQwMjg4MjMsImV4cCI6MjA3OTYwNDgyM30.1u4up2ZZ3BUo4p2hHw72Ne4a_qqvB9efwD-Tp4D9sBA';

  // Edge Function URL for DeepSeek API proxy (fixes CORS issues on web)
  static const String deepSeekEdgeFunctionUrl =
      'https://gjyikixqeqklbdjakmqu.supabase.co/functions/v1/deepseek-proxy';

  static const String appName = 'CV Manager AI';
  static const String websiteUrl = 'https://cvmanagerai.com';
  static const String supportEmail = 'support@cvmanagerai.com';
}
