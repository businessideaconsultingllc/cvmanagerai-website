import json
import os

# Base directory for ARB files
arb_dir = r"c:\Users\Lenovo\OneDrive\Desktop\CV APP with antigravity\flutter_cv_app\lib\l10n\arb"

# Certificate translations for each language
certificate_translations = {
    "app_en.arb": {
        "certificates": "Certificates",
        "certificate": "Certificate",
        "addCertificate": "Add Certificate",
        "editCertificate": "Edit Certificate",
        "certificateName": "Certificate Name",
        "issuer": "Issuer",
        "issueDate": "Issue Date",
        "noCertificates": "No certificates added yet."
    },
    "app_ar.arb": {
        "certificates": "الشهادات",
        "certificate": "شهادة",
        "addCertificate": "إضافة شهادة",
        "editCertificate": "تعديل الشهادة",
        "certificateName": "اسم الشهادة",
        "issuer": "الجهة المانحة",
        "issueDate": "تاريخ الإصدار",
        "noCertificates": "لم تتم إضافة شهادات بعد."
    },
    "app_es.arb": {
        "certificates": "Certificaciones",
        "certificate": "Certificación",
        "addCertificate": "Agregar Certificación",
        "editCertificate": "Editar Certificación",
        "certificateName": "Nombre de Certificación",
        "issuer": "Emisor",
        "issueDate": "Fecha de Emisión",
        "noCertificates": "No se han agregado certificaciones aún."
    },
    "app_fr.arb": {
        "certificates": "Certifications",
        "certificate": "Certification",
        "addCertificate": "Ajouter une Certification",
        "editCertificate": "Modifier la Certification",
        "certificateName": "Nom de la Certification",
        "issuer": "Émetteur",
        "issueDate": "Date d'Émission",
        "noCertificates": "Aucune certification ajoutée pour le moment."
    },
    "app_nl.arb": {
        "certificates": "Certificaten",
        "certificate": "Certificaat",
        "addCertificate": "Certificaat Toevoegen",
        "editCertificate": "Certificaat Bewerken",
        "certificateName": "Certificaatnaam",
        "issuer": "Uitgever",
        "issueDate": "Uitgiftedatum",
        "noCertificates": "Nog geen certificaten toegevoegd."
    },
    "app_de.arb": {
        "certificates": "Zertifikate",
        "certificate": "Zertifikat",
        "addCertificate": "Zertifikat Hinzufügen",
        "editCertificate": "Zertifikat Bearbeiten",
        "certificateName": "Zertifikatsname",
        "issuer": "Aussteller",
        "issueDate": "Ausstellungsdatum",
        "noCertificates": "Noch keine Zertifikate hinzugefügt."
    },
    "app_ru.arb": {
        "certificates": "Сертификаты",
        "certificate": "Сертификат",
        "addCertificate": "Добавить Сертификат",
        "editCertificate": "Редактировать Сертификат",
        "certificateName": "Название Сертификата",
        "issuer": "Выдавший Орган",
        "issueDate": "Дата Выдачи",
        "noCertificates": "Сертификаты ещё не добавлены."
    }
}

# Process each ARB file
for filename, translations in certificate_translations.items():
    filepath = os.path.join(arb_dir, filename)
    
    # Read the existing file
    with open(filepath, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    # Add certificate translations with metadata
    for key, value in translations.items():
        if key not in data:
            data[key] = value
            # Add metadata for the key
            data[f"@{key}"] = {"description": f"{key.replace('_', ' ').title()} label"}
    
    # Write back to file with proper formatting
    with open(filepath, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=4)
    
    print(f"Updated {filename}")

print("\nAll ARB files updated successfully!")
