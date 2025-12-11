import json
import os

# Path to the ARB files
arb_dir = r'c:\Users\Lenovo\OneDrive\Desktop\CV APP with antigravity\flutter_cv_app\lib\l10n\arb'

# Translation mapping for "home"
translations = {
    'app_en.arb': 'Home',
    'app_es.arb': 'Inicio',
    'app_fr.arb': 'Accueil',
    'app_ar.arb': 'الصفحة الرئيسية',
    'app_de.arb': 'Startseite',
    'app_nl.arb': 'Home',
    'app_ru.arb': 'Главная',
}

for filename, translation in translations.items():
    filepath = os.path.join(arb_dir, filename)
    
    # Read the file
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Parse JSON
    data = json.loads(content)
    
    # Check if 'home' already exists
    if 'home' not in data:
        # Create new dict with home inserted after @@locale
        new_data = {}
        for key, value in data.items():
            new_data[key] = value
            # Insert after appTitle meta
            if key == '@appTitle':
                new_data['home'] = translation
                new_data['@home'] = {'description': 'Home navigation label'}
        
        # Write back
        with open(filepath, 'w', encoding='utf-8') as f:
            json.dump(new_data, f, ensure_ascii=False, indent=4)
        
        print(f'Added "home" to {filename}')
    else:
        print(f'"home" already exists in {filename}')

print('Done!')
