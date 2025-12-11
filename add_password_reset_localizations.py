import json
import os

# Path to the ARB files
arb_dir = r'c:\Users\Lenovo\OneDrive\Desktop\CV APP with antigravity\flutter_cv_app\lib\l10n\arb'

# Localization keys to add
localizations = {
    'app_en.arb': {
        'forgotPassword': 'Forgot Password?',
        'resetPassword': 'Reset Password',
        'enterEmailToReset': 'Enter your email address and we\'ll send you a link to reset your password.',
        'sendResetLink': 'Send Reset Link',
        'resetLinkSent': 'Reset Link Sent!',
        'checkYourEmail': 'Please check your email for instructions to reset your password.',
        'backToLogin': 'Back to Login',
        'pleaseEnterValidEmail': 'Please enter a valid email address',
    },
    'app_es.arb': {
        'forgotPassword': '¿Olvidó su contraseña?',
        'resetPassword': 'Restablecer contraseña',
        'enterEmailToReset': 'Ingrese su dirección de correo electrónico y le enviaremos un enlace para restablecer su contraseña.',
        'sendResetLink': 'Enviar enlace de restablecimiento',
        'resetLinkSent': '¡Enlace de restablecimiento enviado!',
        'checkYourEmail': 'Revise su correo electrónico para obtener instrucciones para restablecer su contraseña.',
        'backToLogin': 'Volver al inicio de sesión',
        'pleaseEnterValidEmail': 'Por favor ingrese una dirección de correo electrónico válida',
    },
    'app_fr.arb': {
        'forgotPassword': 'Mot de passe oublié?',
        'resetPassword': 'Réinitialiser le mot de passe',
        'enterEmailToReset': 'Entrez votre adresse e-mail et nous vous enverrons un lien pour réinitialiser votre mot de passe.',
        'sendResetLink': 'Envoyer le lien de réinitialisation',
        'resetLinkSent': 'Lien de réinitialisation envoyé!',
        'checkYourEmail': 'Veuillez vérifier votre e-mail pour des instructions de réinitialisation de mot de passe.',
        'backToLogin': 'Retour à la connexion',
        'pleaseEnterValidEmail': 'Veuillez entrer une adresse e-mail valide',
    },
    'app_ar.arb': {
        'forgotPassword': 'نسيت كلمة المرور؟',
        'resetPassword': 'إعادة تعيين كلمة المرور',
        'enterEmailToReset': 'أدخل عنوان بريدك الإلكتروني وسنرسل لك رابطًا لإعادة تعيين كلمة المرور.',
        'sendResetLink': 'إرسال رابط إعادة التعيين',
        'resetLinkSent': 'تم إرسال رابط إعادة التعيين!',
        'checkYourEmail': 'يرجى التحقق من بريدك الإلكتروني للحصول على تعليمات إعادة تعيين كلمة المرور.',
        'backToLogin': 'العودة إلى تسجيل الدخول',
        'pleaseEnterValidEmail': 'الرجاء إدخال عنوان بريد إلكتروني صالح',
    },
    'app_de.arb': {
        'forgotPassword': 'Passwort vergessen?',
        'resetPassword': 'Passwort zurücksetzen',
        'enterEmailToReset': 'Geben Sie Ihre E-Mail-Adresse ein und wir senden Ihnen einen Link zum Zurücksetzen Ihres Passworts.',
        'sendResetLink': 'Zurücksetzungslink senden',
        'resetLinkSent': 'Zurücksetzungslink gesendet!',
        'checkYourEmail': 'Bitte überprüfen Sie Ihre E-Mail für Anweisungen zum Zurücksetzen Ihres Passworts.',
        'backToLogin': 'Zurück zur Anmeldung',
        'pleaseEnterValidEmail': 'Bitte geben Sie eine gültige E-Mail-Adresse ein',
    },
    'app_nl.arb': {
        'forgotPassword': 'Wachtwoord vergeten?',
        'resetPassword': 'Wachtwoord resetten',
        'enterEmailToReset': 'Voer uw e-mailadres in en we sturen u een link om uw wachtwoord te resetten.',
        'sendResetLink': 'Resetlink verzenden',
        'resetLinkSent': 'Resetlink verzonden!',
        'checkYourEmail': 'Controleer uw e-mail voor instructies om uw wachtwoord te resetten.',
        'backToLogin': 'Terug naar inloggen',
        'pleaseEnterValidEmail': 'Voer een geldig e-mailadres in',
    },
    'app_ru.arb': {
        'forgotPassword': 'Забыли пароль?',
        'resetPassword': 'Сбросить пароль',
        'enterEmailToReset': 'Введите свой адрес электронной почты, и мы вышлем вам ссылку для сброса пароля.',
        'sendResetLink': 'Отправить ссылку для сброса',
        'resetLinkSent': 'Ссылка для сброса отправлена!',
        'checkYourEmail': 'Проверьте свою электронную почту на наличие инструкций по сбросу пароля.',
        'backToLogin': 'Вернуться к входу',
        'pleaseEnterValidEmail': 'Пожалуйста, введите действительный адрес электронной почты',
    },
}

for filename, translations in localizations.items():
    filepath = os.path.join(arb_dir, filename)
    
    # Read the file
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Parse JSON
    data = json.loads(content)
    
    # Find a good insertion point (after 'home' key)
    new_data = {}
    for key, value in data.items():
        new_data[key] = value
        # Insert after @home meta
        if key == '@home':
            for trans_key, trans_value in translations.items():
                if trans_key not in data:
                    new_data[trans_key] = trans_value
                    new_data[f'@{trans_key}'] = {'description': f'{trans_key} text'}
    
    # Write back
    with open(filepath, 'w', encoding='utf-8') as f:
        json.dump(new_data, f, ensure_ascii=False, indent=4)
    
    print(f'Added password reset keys to {filename}')

print('Done!')
