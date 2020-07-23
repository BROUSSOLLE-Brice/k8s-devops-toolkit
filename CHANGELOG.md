# Changelog

Toutes les changements relatives au projet sont documentés dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
et le projet suit les pratiques [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- :heavy_plus_sign: Ajout des alias docker dcc et dci pour le nettoyage de docker.
- :heavy_plus_sign: Ajout de la commande upgrade pour la mise à jour automatique.

### Changed

- :zap: Si option `DOCKER` actif l'option `AS_ROOT` est automatiquement actif aussi.
- :zap: Auto inclusion de `/bin/bash -ic` quand CMD est invoqué.

### Deprecated

### Removed

### Fixed

- :bug: Activation volume partagés avec le user Root quand celui-ci est actif.

### Security

## [0.8.0] - 2020-07-22

### Commit comments

- :sparkles: Ajout des profiles pour le build
- :sparkles: Possibilité de monter plusieurs ports sur une même instance de KDT
- :wastebasket: Netoyage d‘éléments inutiles
- :wastebasket: Suppression de wget
- :wastebasket: Suppression de Google Command Interactive
- :pencil: Mise à jour de la documentation
- :wastebasket: Suppression de Krewn

### Added

- :sparkles: Ajout des profiles pour le build
- :sparkles: Possibilité de monter plusieurs ports sur une même instance de KDT

### Changed

- :wastebasket: Netoyage d'éléments inutiles
- :pencil: Mise à jour de la documentation

### Deprecated

### Removed

- :wastebasket: Suppression de Krew
- :wastebasket: Suppression de Google Command Interactive
- :wastebasket: Suppression de wget

### Fixed

### Security

## [0.7.2] - 2020-06-17

### Commit comments

- :zap: Ajout de la capacité d‘exécuter directement des commandes
- :recycle: Suppression d‘éléments inutile dans le changelog
- :bug: Correction de la comparaison dans le changelogn

### Added

### Changed

### Deprecated

### Removed

### Fixed

### Security

## [0.7.1] - 2020-06-17

### Commit comments

- :bug: Fix changelog updaten

### Added

### Changed

### Deprecated

### Removed

### Fixed

### Security


[Unreleased]: https://gitlab.com/dolmen-tech/tools/k8s-devops-toolkit/compare/v0.8.0...master
[0.8.0]: https://gitlab.com/dolmen-tech/tools/k8s-devops-toolkit/compare/v0.7.2...v0.8.0
[0.7.2]: https://gitlab.com/dolmen-tech/tools/k8s-devops-toolkit/compare/v0.7.1...v0.7.2
[0.7.1]: https://gitlab.com/dolmen-tech/tools/k8s-devops-toolkit/compare/v0.7.0...v0.7.1
