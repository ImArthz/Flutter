# Advanced Trees & Data Structures ðŸŒ²

ðŸŒ **[Read in English](README.en.md)**

**Projeto prÃ¡tico de Algoritmos e Estrutura de Dados 2 (AED2)**

[![Build APK & LaTeX](https://github.com/ImArthz/Flutter/actions/workflows/build_and_release.yml/badge.svg)](https://github.com/ImArthz/Flutter/actions/workflows/build_and_release.yml)

> **Autor:** Arthur de Oliveira MendonÃ§a  
> **Curso:** Engenharia da ComputaÃ§Ã£o  
> **InstituiÃ§Ã£o:** CEFET-MG DivinÃ³polis  
> **Professor:** Michel Pires da Silva  

Este projeto Ã© um estudo prÃ¡tico e detalhado sobre Estruturas de Dados AvanÃ§adas, contemplando a implementaÃ§Ã£o, anÃ¡lise assintÃ³tica e benchmark das seguintes Ã¡rvores:
1. Splay Tree
2. Treap
3. Trie
4. Patricia Tree (Radix Tree)
5. KD-Tree

O repositÃ³rio contÃ©m trÃªs partes principais organizadas nesta pasta:
- ðŸ“± `app_flutter/`: Aplicativo interativo em Flutter que renderiza as Ã¡rvores e permite operÃ¡-las passo a passo com um simulador.
- ðŸ“ˆ `scripts_benchmark/`: Scripts Python utilizados para gerar os testes de estresse, complexidade de tempo e memÃ³ria.
- ðŸ“„ `artigo_academico/`: Artigo cientÃ­fico completo escrito em LaTeX e grÃ¡ficos plotados do benchmark.

---

## ðŸ“¥ Downloads (Releases)

VocÃª nÃ£o precisa compilar o projeto para testar ou ler. Todos os arquivos sÃ£o gerados automaticamente pelo GitHub Actions!

- **[ðŸ“± Baixar APK do Aplicativo (Android)](https://github.com/ImArthz/Flutter/releases/latest/download/arvores_app-v1.0.1.apk)**
- **[ðŸ“„ Baixar Artigo CientÃ­fico em PDF (PT-BR)](https://github.com/ImArthz/Flutter/releases/latest/download/artigo_arvores.pdf)**
- **[ðŸ“„ Baixar Artigo CientÃ­fico em PDF (InglÃªs)](https://github.com/ImArthz/Flutter/releases/latest/download/article_trees.pdf)**

*(Caso os links nÃ£o abram, acesse a aba **[Releases](https://github.com/ImArthz/Flutter/releases)** no GitHub).*

---

## ðŸ› ï¸ Como Executar Localmente

### Flutter App
```bash
cd app_flutter
flutter pub get
flutter run
```

### Benchmarks (Python)
```bash
cd scripts_benchmark
pip install matplotlib seaborn pandas
python benchmark.py
python plot_benchmark.py
```
