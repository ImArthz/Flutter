
# Json Generator Flutter App

Aplicação desenvolvida em Flutter para consumo de dados JSON utilizando API externa, com exibição dinâmica em interface gráfica moderna.

-------------------------------------------------------------------

# Sobre o Projeto

O projeto tem como objetivo demonstrar:

- Consumo de API REST
- Manipulação de JSON
- Conversão de dados para objetos/classes
- Exibição dinâmica utilizando ListView
- Navegação entre registros
- Utilização de imagens remotas
- Organização visual com Flutter

A aplicação realiza a leitura de uma API do Json Generator contendo múltiplos registros de usuários fictícios.

-------------------------------------------------------------------

# Funcionalidades

[✓] Consumo de API HTTP
[✓] Conversão JSON → Classe Dart
[✓] Navegação entre registros
[✓] Listagem dinâmica com ListView.builder
[✓] Seleção visual de itens
[✓] Exibição de foto de perfil
[✓] Tela "Sobre" integrada
[✓] Redirecionamento para GitHub
[✓] Interface responsiva e moderna

-------------------------------------------------------------------

# Tecnologias Utilizadas

- Flutter
- Dart
- HTTP Package
- JSON Generator API
- URL Launcher

-------------------------------------------------------------------

# Conceitos Aplicados

## StatefulWidget

Utilizado para atualização dinâmica da interface durante:

- carregamento dos dados
- troca de item selecionado
- renderização da lista

-------------------------------------------------------------------

## Consumo de API REST

A aplicação utiliza requisição HTTP GET para acessar dados externos:
```
final response = await http.get(uri);
```
-------------------------------------------------------------------

## Desserialização JSON

Os dados recebidos são convertidos em objetos Dart através do método:
```
factory Item.fromJson(Map<String, dynamic> dados)
```
-------------------------------------------------------------------

## ListView.builder

Renderização otimizada para grandes quantidades de dados.
```
ListView.builder(
  itemCount: lista.length,
)
```
-------------------------------------------------------------------

## Navegação entre telas

Implementada utilizando:
```
Navigator.push()
```
-------------------------------------------------------------------

# Estrutura dos Dados

Cada registro possui:
```
{
  "id": 1,
  "nome": "João Silva",
  "telefone": "(31)99999-9999",
  "endereco": "Belo Horizonte - MG",
  "fotoPerfil": "https://picsum.photos/200",
  "observacao": "Usuário cadastrado."
}
```
-------------------------------------------------------------------

# Interface

O aplicativo possui:

- painel principal de cadastro
- foto de perfil
- informações do usuário
- observações
- navegação entre registros
- lista inferior com visual customizado

-------------------------------------------------------------------

# Repositório

<div align="center">

<a href="https://github.com/ImArthz/Flutter/tree/master/jsongenerator">
    <img src="https://img.shields.io/badge/Abrir%20Repositorio-181717?style=for-the-badge&logo=github&logoColor=white">
</a>

<br>

<a href="https://github.com/ImArthz">
    <img src="https://img.shields.io/badge/Meu%20GitHub-0A66C2?style=for-the-badge&logo=github&logoColor=white">
</a>

</div>

-------------------------------------------------------------------

# Dependências
```
dependencies:
  flutter:
    sdk: flutter

  http: ^1.2.1
  url_launcher: ^6.2.5
```
-------------------------------------------------------------------

# Como Executar

## 1. Clone o repositório
```bash
git clone https://github.com/ImArthz/Flutter.git
```
-------------------------------------------------------------------

## 2. Entre na pasta
```
cd Flutter/jsongenerator
```
-------------------------------------------------------------------

## 3. Instale as dependências
```
flutter pub get
```
-------------------------------------------------------------------

## 4. Execute o projeto
```
flutter run
```
-------------------------------------------------------------------
# Autor



## Arthur Mendonça
<div align="center">

<img src="https://avatars.githubusercontent.com/u/135072001?v=4" width="140px" />

<br><br>

Estudante de Engenharia da Computação no CEFET-MG.

<br>

<a href="https://github.com/ImArthz">
    <img src="https://img.shields.io/badge/GitHub-ImArthz-181717?style=for-the-badge&logo=github&logoColor=white">
</a>

</div>

-------------------------------------------------------------------

# Observação

Projeto desenvolvido para fins acadêmicos e prática de consumo de APIs utilizando Flutter.
