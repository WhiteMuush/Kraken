# Kraken — Pentest Orchestration Framework

Kraken est un framework bash modulaire pour automatiser des tâches courantes de reconnaissance, scan, énumération web et génération de rapports. Conçu pour une utilisation en environnement autorisé uniquement.

Auteur : Melvin PETIT 
Version embarquée : 0.1.0

## Fonctionnalités principales
- Bannière ASCII et interface TUI simple
- Modules modulaires :
    - Reconnaissance (DNS, whois, sous-domaines)
    - Scan de ports (nmap ou scan bash basique)
    - Énumération web (headers, directories, robots.txt, détection technologies)
    - Évaluation basique de vulnérabilités (headers, SSL)
    - Génération d’un rapport HTML consolidé
- Enregistrement automatique des résultats dans un répertoire de sortie horodaté

## Prérequis
Outils recommandés (fonctionnalité complète) :
- bash (obligatoire)
- nmap
- curl
- host (ou nslookup/getent)
- whois
- openssl
- subfinder (optionnel pour l’énumération de sous-domaines)

Installer les paquets via le gestionnaire de votre distribution si nécessaire.

## Démarrage rapide
1. Rendre le script exécutable :
     ```bash
     chmod +x kraken.sh
     ```
2. Lancer Kraken :
     ```bash
     ./kraken.sh
     ```
3. Utiliser le menu pour choisir un module (Reconnaissance, Scan, Web, Vuln, Report).

Les résultats sont sauvegardés sous un répertoire créé à l’exécution : `kraken_output_YYYYMMDD_HHMMSS/`.

## Structure de sortie
- recon_<target>/ — dns_records.txt, subdomains.txt, whois.txt, ...
- scan_<target>/ — nmap_quick.txt, nmap_services.txt ou bash_scan.txt
- web_<target>/ — headers.txt, directories.txt, technologies.txt, robots.txt
- vuln_<target>/ — ssl_cert.txt, findings.txt
- kraken_report_<timestamp>.html — rapport HTML consolidé

## Configuration & Détection d’outils
Le script affiche l’état des outils disponibles au démarrage. Kraken fonctionne avec des fonctionnalités réduites si certains outils manquent.

## Bonnes pratiques & avertissement légal
- N’utiliser Kraken que sur des cibles dont vous avez l’autorisation explicite.
- Respecter la loi et les règles d’éthique professionnelle.
- Ce framework réalise des actions intrusives (scans, requêtes) — tester en environnement contrôlé.

## Contribution
Suggestions et contributions bienvenues via le dépôt GitHub de l’auteur. Ajouter un fichier LICENSE au dépôt pour préciser les conditions d’utilisation.

## Remarques
- Le script contient des fonctions et templates CSS/HTML pour générer un rapport lisible.
- Pour des évaluations approfondies, compléter Kraken avec des outils spécialisés et des workflows de validation manuelle.

---

Kraken fourni un point de départ pratique pour l’orchestration de tâches de pentest automatisées. Adapter et enrichir selon vos besoins et le cadre légal.