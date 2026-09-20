<p align="center">
  <h1 align="center">Advanced Trees & Data Structures</h1>
</p>

<p align="center">
  <strong>Projeto pratico de Algoritmos e Estrutura de Dados 2 (AED2)</strong>
</p>

<p align="center">
  <a href="README.en.md">Read in English</a>
</p>

<p align="center">
  <a href="https://github.com/ImArthz/Flutter/actions/workflows/build_and_release.yml">
    <img src="https://github.com/ImArthz/Flutter/actions/workflows/build_and_release.yml/badge.svg" alt="Build Status">
  </a>
  <img src="https://img.shields.io/badge/Flutter-3.24-blue?logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.5-0175C2?logo=dart" alt="Dart">
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20Windows%20%7C%20Linux-brightgreen" alt="Platforms">
  <img src="https://img.shields.io/badge/License-MIT-yellow" alt="License">
</p>

---

> **Autor:** Arthur de Oliveira Mendonca  
> **Curso:** Engenharia da Computacao  
> **Instituicao:** CEFET-MG Divinopolis  
> **Professor:** Michel Pires da Silva  

---

## Sobre o Projeto

Este projeto e um estudo pratico e detalhado sobre **Estruturas de Dados Avancadas**, contemplando a implementacao, analise assintotica e benchmark das seguintes arvores:

| # | Estrutura | Tipo |
|---|-----------|------|
| 1 | **Splay Tree** | Arvore Binaria Auto-ajustavel |
| 2 | **Treap** | Arvore Binaria Probabilistica |
| 3 | **Trie** | Arvore de Prefixos |
| 4 | **Patricia Tree** | Radix Tree (Trie Compacta) |
| 5 | **KD-Tree** | Arvore de Busca Espacial 2D |

O repositorio contem tres partes principais:
- **`app_flutter/`** - Aplicativo interativo em Flutter que renderiza as arvores e permite opera-las passo a passo com um simulador automatico.
- **`scripts_benchmark/`** - Scripts Python utilizados para gerar os testes de estresse, complexidade de tempo e memoria.
- **`artigo_academico/`** - Artigo cientifico completo escrito em LaTeX e graficos plotados do benchmark.

---

## Downloads

> **Nota:** O aplicativo foi desenhado para a interface mobile (celular), mas funciona perfeitamente no Windows e Linux como aplicativo desktop. Todos os arquivos abaixo sao gerados automaticamente pelo **GitHub Actions** a cada commit.

### Aplicativo

<table>
  <tr>
    <td align="center"><strong>Android (APK)</strong></td>
    <td align="center"><strong>Windows (EXE)</strong></td>
    <td align="center"><strong>Linux</strong></td>
  </tr>
  <tr>
    <td align="center">
      <a href="https://github.com/ImArthz/Flutter/releases/latest/download/arvores_app-v1.0.3.apk">
        <img src="https://img.shields.io/badge/Download-Android%20APK-34A853?style=for-the-badge&logo=android&logoColor=white" alt="Download APK">
      </a>
    </td>
    <td align="center">
      <a href="https://github.com/ImArthz/Flutter/releases/latest/download/arvores_app_windows.zip">
        <img src="https://img.shields.io/badge/Download-Windows%20ZIP-0078D4?style=for-the-badge&logo=windows&logoColor=white" alt="Download Windows">
      </a>
    </td>
    <td align="center">
      <a href="https://github.com/ImArthz/Flutter/releases/latest/download/arvores_app_linux.tar.gz">
        <img src="https://img.shields.io/badge/Download-Linux%20tar.gz-FCC624?style=for-the-badge&logo=linux&logoColor=black" alt="Download Linux">
      </a>
    </td>
  </tr>
</table>

### Artigos Cientificos

<table>
  <tr>
    <td align="center">
      <a href="https://github.com/ImArthz/Flutter/releases/latest/download/artigo_arvores.pdf">
        <img src="https://img.shields.io/badge/Artigo-Portugues%20(PDF)-red?style=for-the-badge&logo=adobeacrobatreader&logoColor=white" alt="PDF PT-BR">
      </a>
    </td>
    <td align="center">
      <a href="https://github.com/ImArthz/Flutter/releases/latest/download/article_trees.pdf">
        <img src="https://img.shields.io/badge/Article-English%20(PDF)-red?style=for-the-badge&logo=adobeacrobatreader&logoColor=white" alt="PDF EN">
      </a>
    </td>
  </tr>
</table>

> Se os links acima nao funcionarem, acesse a aba **[Releases](https://github.com/ImArthz/Flutter/releases)** no GitHub.

---

## Como Instalar e Executar

### Android
1. Baixe o arquivo **APK** acima.
2. No celular, abra o arquivo e permita a instalacao de fontes desconhecidas.
3. O aplicativo sera instalado e pronto para usar.

### Windows
1. Baixe o arquivo **arvores_app_windows.zip** acima.
2. **Extraia** o conteudo do ZIP (botao direito > Extrair Tudo).
3. Dentro da pasta extraida, execute o arquivo **`arvores_app.exe`**.
4. **Importante:** Nao mova o `.exe` para fora da pasta. Ele precisa estar junto com os arquivos `data/` e `flutter_windows.dll` para funcionar.

### Linux
1. Baixe o arquivo **arvores_app_linux.tar.gz** acima.
2. Extraia com o comando:
   ```bash
   tar -xzf arvores_app_linux.tar.gz
   ```
3. De permissao de execucao e rode:
   ```bash
   chmod +x arvores_app
   ./arvores_app
   ```
4. **Dependencias:** Necessita das bibliotecas GTK3 instaladas. Na maioria das distros Ubuntu/Debian:
   ```bash
   sudo apt-get install libgtk-3-0
   ```

---

## Como Compilar Localmente

### Flutter App
```bash
cd app_flutter
flutter pub get
flutter run              # Roda no dispositivo conectado
flutter build apk        # Gera APK Android
flutter build windows    # Gera EXE Windows
flutter build linux      # Gera app Linux
```

### Benchmarks (Python)
```bash
cd scripts_benchmark
pip install matplotlib seaborn pandas
python benchmark.py
python plot_benchmark.py
```

---

<p align="center">
  Feito com muito cafe e codigo por <a href="https://github.com/ImArthz"><strong>@ImArthz</strong></a>
</p>
