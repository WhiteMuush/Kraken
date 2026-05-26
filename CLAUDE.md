# Kraken — Instructions Claude Code

## Rôle du projet
Framework bash modulaire de pentesting. Orchestre reconnaissance, scanning, énumération et reporting. Chaque module ("tentacule") est indépendant et remplaçable. Exécution parallèle, output structuré.

## Règle des 3 couches
1. `/graphify .` → lire le graph AST
2. Vault `F:\DevOps\Brain\Kraken\` → décisions et snippets passés
3. Sources uniquement si nécessaire

## Architecture
```
kraken.sh            ← point d'entrée, orchestrateur
requirements.txt     ← outils requis
```

## Conventions
- Bash >= 4.0
- Architecture modulaire : chaque module est un fichier bash indépendant
- Exécution parallèle via background jobs
- Output structuré (dossiers horodatés)

## Vault Brain
- `F:\DevOps\Brain\Kraken\decisions\`
- `F:\DevOps\Brain\Kraken\snippets\`
- `F:\DevOps\Brain\Kraken\sessions\`
