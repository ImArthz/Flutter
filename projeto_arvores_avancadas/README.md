# Advanced Trees & Data Structures

[Read in English](README.en.md)

**Projeto pratico de Algoritmos e Estrutura de Dados 2 (AED2)**

[![Build APK & LaTeX](https://github.com/ImArthz/Flutter/actions/workflows/build_and_release.yml/badge.svg)](https://github.com/ImArthz/Flutter/actions/workflows/build_and_release.yml)

> **Autor:** Arthur de Oliveira Mendonca  
> **Curso:** Engenharia da Computacao  
> **Instituicao:** CEFET-MG Divinopolis  
> **Professor:** Michel Pires da Silva  

Este projeto e um estudo pratico e detalhado sobre Estruturas de Dados Avancadas, contemplando a implementacao, analise assintotica e benchmark das seguintes arvores:
1. Splay Tree
2. Treap
3. Trie
4. Patricia Tree (Radix Tree)
5. KD-Tree

O repositorio contem tres partes principais organizadas nesta pasta:
- `app_flutter/`: Aplicativo interativo em Flutter que renderiza as arvores e permite opera-las passo a passo com um simulador automatico.
- `scripts_benchmark/`: Scripts Python utilizados para gerar os testes de estresse, complexidade de tempo e memoria.
- `artigo_academico/`: Artigo cientifico completo escrito em LaTeX e graficos plotados do benchmark.

---

## Downloads (Releases)

Voce nao precisa compilar o projeto para testar ou ler. Todos os arquivos sao gerados automaticamente pelo GitHub Actions!

- **[Baixar APK do Aplicativo (Android)](https://github.com/ImArthz/Flutter/releases/latest/download/arvores_app-v1.0.3.apk)**
- **[Baixar Artigo Cientifico em PDF (PT-BR)](https://github.com/ImArthz/Flutter/releases/latest/download/artigo_arvores.pdf)**
- **[Baixar Artigo Cientifico em PDF (Ingles)](https://github.com/ImArthz/Flutter/releases/latest/download/article_trees.pdf)**

*(Caso os links nao abram, acesse a aba **[Releases](https://github.com/ImArthz/Flutter/releases)** no GitHub).*

---

## Como Executar Localmente

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
