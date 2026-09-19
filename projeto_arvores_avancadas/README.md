# Advanced Trees & Data Structures 🌳
**Projeto prático de Algoritmos e Estrutura de Dados 2 (AED2)**

[![Build APK & LaTeX](https://github.com/ImArthz/Flutter/actions/workflows/build_and_release.yml/badge.svg)](https://github.com/ImArthz/Flutter/actions/workflows/build_and_release.yml)

> **Autor:** Arthur de Oliveira Mendonça  
> **Curso:** Engenharia da Computação  
> **Instituição:** CEFET-MG Divinópolis  
> **Professor:** Michel Pires da Silva  

Este projeto é um estudo prático e detalhado sobre Estruturas de Dados Avançadas, contemplando a implementação, análise assintótica e benchmark das seguintes árvores:
1. Splay Tree
2. Treap
3. Trie
4. Patricia Tree (Radix Tree)
5. KD-Tree

O repositório contém três partes principais organizadas nesta pasta:
- 📱 `app_flutter/`: Aplicativo interativo em Flutter que renderiza as árvores e permite operá-las passo a passo.
- 📊 `scripts_benchmark/`: Scripts Python utilizados para gerar os testes de estresse, complexidade de tempo e memória.
- 📄 `artigo_academico/`: Artigo científico completo escrito em LaTeX e gráficos plotados do benchmark.

---

## 📥 Downloads (Releases)

Você não precisa compilar o projeto para testar ou ler. Todos os arquivos são gerados automaticamente pelo GitHub Actions!

- **[📱 Baixar APK do Aplicativo (Android)](https://github.com/ImArthz/Flutter/releases/latest/download/arvores_app-release.apk)**
- **[📄 Baixar Artigo Científico em PDF](https://github.com/ImArthz/Flutter/releases/latest/download/artigo_arvores.pdf)**

*(Caso os links não abram, acesse a aba **[Releases](https://github.com/ImArthz/Flutter/releases)** no menu lateral do GitHub para baixar os arquivos).*

---

## 🇺🇸 English Version

This project is a practical study on Advanced Data Structures for the AED2 course, covering the implementation, asymptotic analysis, and benchmarking of Splay Trees, Treaps, Tries, Patricia Trees, and KD-Trees.

**Folder Structure:**
- `app_flutter/`: Interactive Flutter application for visualizing tree operations.
- `scripts_benchmark/`: Python scripts for generating stress tests, time complexity, and memory metrics.
- `artigo_academico/`: Complete scientific paper written in LaTeX with plotted benchmark charts.

### Downloads

- **[📱 Download Flutter APK (Android)](https://github.com/ImArthz/Flutter/releases/latest/download/arvores_app-release.apk)**
- **[📄 Download Scientific Paper (PDF)](https://github.com/ImArthz/Flutter/releases/latest/download/artigo_arvores.pdf)**

---

## 🚀 Como Executar Localmente (How to run locally)

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
