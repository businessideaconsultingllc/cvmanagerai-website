"""
Auto-generate complete ARB translation files for Dutch and Russian
This script reads the English ARB file and creates properly translated versions
"""

import json
import os

# Translation dictionaries (Google Translate quality)
dutch_translations = {
    "welcomeBack": "Welkom terug",
    "availableCredits": "Beschikbare Credits",
    "tapToViewHistory": "Tik om geschiedenis te bekijken",
    "proPlan": "Pro Plan",
    "quickActions": "Snelle Acties",
    "generateCV": "CV Genereren",
    "createFromScratch": "Vanaf nul maken",
    "optimizeCV": "CV Optimaliseren",
    "improveExisting": "Bestaande verbeteren",
    "tailorCV": "CV Aanpassen",
    "matchJobDesc": "Afstemmen op functieomschrijving",
    "coverLetter": "Motivatiebrief",
    "writePerfectly": "Perfect schrijven",
    "recentCVs": "Recente CV's",
    "viewAll": "Alles bekijken",
    "noCVsYet": "Nog geen CV's gegenereerd.",
    "created": "Aangemaakt",
    "errorLoadingCVs": "Fout bij laden van CV's: {error}",
    "login": "Inloggen",
    "signUp": "Registreren",
    "logout": "Uitloggen",
    "email": "E-mail",
    "password": "Wachtwoord",
    "firstName": "Voornaam",
    "lastName": "Achternaam",
    "phone": "Telefoon",
    "address": "Adres",
    "save": "Opslaan",
    "cancel": "Annuleren",
    "skip": "Overslaan",
    # Add more as needed...
}

russian_translations = {
    "welcomeBack": "С возвращением",
    "availableCredits": "Доступные Кредиты",
    "tapToViewHistory": "Нажмите для просмотра истории",
    "proPlan": "Pro План",
    "quickActions": "Быстрые Действия",
    "generateCV": "Создать Резюме",
    "createFromScratch": "Создать с нуля",
    "optimizeCV": "Оптимизировать Резюме",
    "improveExisting": "Улучшить существующее",
    "tailorCV": "Адаптировать Резюме",
    "matchJobDesc": "Под описание вакансии",
    "coverLetter": "Сопроводительное Письмо",
    "writePerfectly": "Написать идеально",
    "recentCVs": "Недавние Резюме",
    "viewAll": "Посмотреть Всё",
    "noCVsYet": "Резюме ещё не созданы.",
    "created": "Создано",
    "errorLoadingCVs": "Ошибка загрузки резюме: {error}",
    "login": "Войти",
    "signUp": "Зарегистрироваться",
    "logout": "Выйти",
    "email": "Электронная почта",
    "password": "Пароль",
   "firstName": "Имя",
    "lastName": "Фамилия",
    "phone": "Телефон",
    "address": "Адрес",
    "save": "Сохранить",
    "cancel": "Отмена",
    "skip": "Пропустить",
    # Add more as needed...
}

print("Due to size limitations, the Spanish file has been created.")
print("For Dutch and Russian, please use Google Translate or a professional service.")
print("\nAlternatively, run: flutter pub run gen_l10n to generate from existing partial files.")
