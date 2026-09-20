# Advanced Trees & Data Structures 🌲

🌍 **[Read in English](README.en.md)**

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
- 📱 `app_flutter/`: Aplicativo interativo em Flutter que renderiza as árvores e permite operá-las passo a passo com um simulador.
- 📈 `scripts_benchmark/`: Scripts Python utilizados para gerar os testes de estresse, complexidade de tempo e memória.
- 📄 `artigo_academico/`: Artigo científico completo escrito em LaTeX e gráficos plotados do benchmark.

---

## 📥 Downloads (Releases)

Você não precisa compilar o projeto para testar ou ler. Todos os arquivos são gerados automaticamente pelo GitHub Actions!

- **[📱 Baixar APK do Aplicativo (Android)](https://github.com/ImArthz/Flutter/releases/latest/download/arvores_app-release.apk)**
- **[📄 Baixar Artigo Científico em PDF (PT-BR)](https://github.com/ImArthz/Flutter/releases/latest/download/artigo_arvores.pdf)**
- **[📄 Baixar Artigo Científico em PDF (Inglês)](https://github.com/ImArthz/Flutter/releases/latest/download/article_trees.pdf)**

*(Caso os links não abram, acesse a aba **[Releases](https://github.com/ImArthz/Flutter/releases)** no GitHub).*

---

## 🛠️ Como Executar Localmente

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
