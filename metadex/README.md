<p align="center">
  <h1 align="center">⚡ MetaDex TCG Studio</h1>
</p>

<p align="center">
  <strong>Plataforma de Inteligência Competitiva, Auditoria de Legalidade e Relatórios Automatizados para Torneios de Pokémon TCG</strong>
</p>

<p align="center">
  <a href="https://github.com/ImArthz/Flutter/actions/workflows/build_and_release.yml">
    <img src="https://github.com/ImArthz/Flutter/actions/workflows/build_and_release.yml/badge.svg" alt="Build Status">
  </a>
  <img src="https://img.shields.io/badge/Flutter-3.47-02569B?logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.13-0175C2?logo=dart" alt="Dart">
  <img src="https://img.shields.io/badge/Platform-Windows%20%7C%20Android%20%7C%20Linux%20%7C%20Web-brightgreen" alt="Platforms">
  <img src="https://img.shields.io/badge/Architecture-DDD%20%2B%20MVVM-FF7A00" alt="DDD + MVVM">
  <img src="https://img.shields.io/badge/License-MIT-yellow" alt="License">
</p>

---

## 📥 Downloads (Releases Oficiais)

> Baixe a versão pronta para uso na sua plataforma preferida. Os pacotes são compilados e publicados nas **[Releases do Repositório](https://github.com/ImArthz/Flutter/releases)**.

<table>
  <tr>
    <td align="center"><strong>🪟 Windows (Desktop EXE)</strong></td>
    <td align="center"><strong>🤖 Android (APK)</strong></td>
    <td align="center"><strong>🐧 Linux (Desktop)</strong></td>
    <td align="center"><strong>🌐 Web Build (HTML5/Canvas)</strong></td>
  </tr>
  <tr>
    <td align="center">
      <a href="https://github.com/ImArthz/Flutter/releases/latest/download/metadex_windows.zip">
        <img src="https://img.shields.io/badge/BAIXAR-Windows%20ZIP%20(.EXE)-0078D4?style=for-the-badge&logo=windows&logoColor=white" alt="Download Windows ZIP">
      </a>
    </td>
    <td align="center">
      <a href="https://github.com/ImArthz/Flutter/releases/latest/download/metadex-v1.0.0.apk">
        <img src="https://img.shields.io/badge/BAIXAR-Android%20APK-34A853?style=for-the-badge&logo=android&logoColor=white" alt="Download Android APK">
      </a>
    </td>
    <td align="center">
      <a href="https://github.com/ImArthz/Flutter/releases/latest/download/metadex_linux.tar.gz">
        <img src="https://img.shields.io/badge/BAIXAR-Linux%20tar.gz-FCC624?style=for-the-badge&logo=linux&logoColor=black" alt="Download Linux tar.gz">
      </a>
    </td>
    <td align="center">
      <a href="https://github.com/ImArthz/Flutter/releases/latest/download/metadex_web.zip">
        <img src="https://img.shields.io/badge/BAIXAR-Web%20Bundle%20ZIP-FF7A00?style=for-the-badge&logo=googlechrome&logoColor=white" alt="Download Web ZIP">
      </a>
    </td>
  </tr>
</table>

<p align="center">
  <a href="https://github.com/ImArthz/Flutter/releases/tag/metadex-v1.0.0">
    <img src="https://img.shields.io/badge/📦%20Ver%20Página%20Completa%20da%20Release%20MetaDex%20v1.0.0-181717?style=for-the-badge&logo=github" alt="Release MetaDex v1.0.0">
  </a>
</p>

---

## 🎯 Sobre o Projeto

O **MetaDex TCG Studio** resolve a fragmentação operacional de torneios locais e regionais sancionados (*Play! Pokémon* — League Challenge, League Cup e ligas semanais), integrando a saída oficial do **TOM (*Tournament Operations Manager*)** com o ecossistema de decklists do **Pokémon TCG Live (PT-BR e EN)** em uma única estação de comando e análise estatística.

### Principais Funcionalidades

| Módulo | Descrição Técnica |
|--------|-------------------|
| **1. Ingestão Oficial TOM (`.tdf` XML & PDF)** | Parser XML `.tdf` nativo com proteção OWASP contra ataques **XXE (`DOCTYPE`/`ENTITY`)**, deduplicação idempotente via hash **SHA-256 (`RN-08`)**, cálculo automático de **W-L-T, Match Points, OWP e OOWP**, além de suporte a colagem direta de tabelas de classificação em PDF do TOM. |
| **2. Proteção de Menores & LGPD (`ADR-006` / `RN-05`)** | Descarte imediato da data de nascimento (`birthdate`) em memória volátil durante o parsing do `.tdf` e abreviação automática de sobrenomes para divisões **Junior** e **Senior** sem consentimento expresso dos responsáveis. |
| **3. Parser Bilíngue PTCG Live & Carta Canônica (`RN-02`)** | Suporte a listas em Português (`Pokémon / Treinador / Energia`) e Inglês (`Pokémon / Trainer / Energy`), sugestões de correção por **distância de edição de Levenshtein** e consolidação de reimpressões (ex.: *Ultra Ball SVI 196* + *Ultra Ball PAF 91*) sob a mesma `CartaCanonica`. |
| **4. Motor de Validação de Legalidade (`RF-06`)** | Padrão *Strategy + Specification* que verifica: **(a)** exatamente 60 cartas; **(b)** máximo de 4 cópias por nome canônico; **(c)** máximo de 1 *ACE SPEC*; **(d)** máximo de 1 Pokémon *Radiant*; **(e)** marca de regulação válida na data do torneio (`G/H/I` vs. `F/G/H` — `RN-01`); e **(f)** *Banlist* oficial. |
| **5. Classificador Híbrido de Arquétipos (`RF-07`)** | Pipeline em 2 estágios combinando **Regras de Assinatura** (âncoras principais/secundárias e exclusões) + **Similaridade de Jaccard Ponderada ($J_w$)**, encaminhando listas *rogue* ($\text{confiança} < 0.55$) para a **Fila de Curadoria do Juiz (`UC14`)**. |
| **6. Motor Estatístico & Analítico (Fase 6.5)** | Cálculo de *Meta Share*, *Taxa de Conversão para o Top Cut*, *Win Rate Bayesiano Suavizado*, **Intervalo de Confiança de Wilson a 95% ($z=1.96$)**, alerta de amostra baixa ($n < 5$, `RN-07`), **Inclusão Ponderada por Desempenho DCG ($\text{IR}_w$)**, **Lista Consenso de 60 Cartas**, **Comparador Diff (`UC7`)** e **Matriz de Matchups Cruzados**. |
| **7. Embargo Anti-Scouting (`RN-03`) & Exportação PDF** | Bloqueio visual automático de decklists enquanto o torneio está `Em Andamento`, paleta **Okabe-Ito** acessível para daltônicos e exportação dupla em **PDF Analítico Multi-Tabelas** ou **Infográfico Visual HD (`RepaintBoundary`)**. |

---

## 🧮 Fundamentos Matemáticos Implementados

1. **Intervalo de Confiança de Wilson (95%, $z = 1.96$):**
   $$\text{IC}_{95\%} = \frac{\hat{p} + \frac{z^2}{2n} \pm z\sqrt{\frac{\hat{p}(1-\hat{p})}{n} + \frac{z^2}{4n^2}}}{1 + \frac{z^2}{n}}$$
2. **Similaridade de Jaccard Ponderada ($J_w$):**
   $$J_w(\mathbf{x}, \mathbf{c}_A) = \frac{\sum_{i} w_i \min(x_i, c_{A,i})}{\sum_{i} w_i \max(x_i, c_{A,i})}$$
   com pesos hierárquicos por papel funcional: Pokémon Atacante Principal ($w = 3.0$), Suporte / Engine ($w = 2.0$), *ACE SPEC* ($w = 2.5$), Trainers ($w = 1.0$) e Energias Básicas ($w = 0.5$).
3. **Taxa de Inclusão Ponderada por Desempenho (DCG):**
   $$p_d = \frac{1}{\log_2(\text{colocacao}_d + 1)}, \qquad \text{IR}_w(c) = \frac{\sum_{d \in D_A(c)} p_d}{\sum_{d \in D_A} p_d}$$

---

## 🛠️ Arquitetura do Projeto

```text
metadex/
├── docs/
│   └── PIPELINE.md                          # Especificação de Engenharia de Software (Fases 1 a 10)
├── lib/
│   ├── main.dart                            # Ponto de entrada e injeção do MultiProvider
│   ├── data/
│   │   └── services/
│   │       ├── pdf_export_service.dart      # Gerador de PDF Analítico Completo + Captura HD
│   │       └── pokemon_tcg_api_service.dart # Integração opcional com API pokemontcg.io
│   ├── domain/
│   │   ├── models/
│   │   │   ├── deck.dart                    # CartaCanonica, DeckCard, Decklist e PtcgLiveParser
│   │   │   ├── metagame.dart                # MetagameStat, CardPresenceStat, DeckDiffItem, MatchupCell
│   │   │   ├── player.dart                  # Player, DivisaoEtaria, LGPD displayName, OWP/OOWP
│   │   │   └── tournament.dart              # EstadoTorneio (Embargo RN-03), Loja, Partida, Auditoria
│   │   └── services/
│   │       ├── analytics_engine.dart        # Wilson 95%, DCG, Lista Consenso 60, Diff e Matchups
│   │       ├── archetype_classifier.dart    # ClassificadorComposto (Assinatura + Jaccard Ponderado)
│   │       ├── deck_validator.dart          # ValidadorDeDecklist (6 regras Strategy/Specification)
│   │       └── tom_tdf_parser.dart          # Parser XML .tdf + PDF TOM + XXE Guard + SHA-256
│   └── ui/
│       ├── screens/
│       │   ├── start_menu_screen.dart       # Dashboard inicial com torneios de demonstração
│       │   └── tournament_editor_screen.dart# Estação de Comando (4 abas) + Viewport Analítico (5 abas)
│       ├── viewmodels/
│       │   └── tournament_editor_viewmodel.dart # Gerenciamento de estado reativo (ChangeNotifier)
│       └── widgets/
│           ├── decklist_view.dart           # Grid visual de cartas com CDN tcgdex/pokemontcg
│           ├── metagame_chart.dart          # Gráfico Donut Okabe-Ito + métricas estatísticas
│           └── podium.dart                  # Pódio Top Cut interativo (Top 4 / Top 8)
└── test/
    └── widget_test.dart                     # Suíte de 10 testes unitários, segurança, LGPD e UI
```

---

## 🚀 Como Instalar e Executar

### 🪟 Windows (Versão Pronta)
1. Clique no botão **[BAIXAR Windows ZIP (.EXE)](https://github.com/ImArthz/Flutter/releases/latest/download/metadex_windows.zip)** no topo deste README.
2. Extraia todo o conteúdo do arquivo `metadex_windows.zip` em uma pasta.
3. Execute **`metadex.exe`** (mantenha a pasta `data/` e as `.dll` no mesmo diretório do executável).

### 🤖 Android (APK)
1. Baixe o arquivo **[metadex-v1.0.0.apk](https://github.com/ImArthz/Flutter/releases/latest/download/metadex-v1.0.0.apk)**.
2. Abra o APK no seu dispositivo Android e autorize a instalação.

### 💻 Compilação Local (Desenvolvedores)
```bash
cd metadex
flutter pub get
dart analyze                 # Verifica 0 erros/warnings estáticos
flutter test                 # Executa a suíte completa de testes (10/10)
flutter run -d windows       # Executa no Windows Desktop
flutter run -d chrome        # Executa no navegador Chrome
```

---

<p align="center">
  Desenvolvido por <a href="https://github.com/ImArthz"><strong>Arthur de Oliveira Mendonça (@ImArthz)</strong></a>
</p>
