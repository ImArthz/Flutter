 
 # DOCUMENTAÇÃO DO APP JOGO DA VELHA (FLUTTER)

 
 Bem-vindo à documentação do aplicativo **Jogo da Velha** desenvolvido em Flutter.
 Este documento explica como o app funciona por dentro, como foi implementado,
 quais estilos foram usados e como você pode personalizar as informações de contato.
 
 -------------------------------------------------------------------
 📱 VISÃO GERAL DO APP
 -------------------------------------------------------------------
 
 O aplicativo é um **Jogo da Velha** (Tic‑Tac‑Toe) para dois jogadores (X e O).
 Ele possui:
 - Tela principal com menu lateral (drawer) e barra de navegação inferior.
 - Tela do jogo, com tabuleiro interativo, indicação de turno e placar ao vivo.
 - Tela de ranking, que mostra estatísticas de vitórias, aproveitamento e quem está na frente.
 - Tela "Sobre", com informações do desenvolvedor, tecnologias utilizadas e contatos.
 
 O estado das **vitórias** (X e O) é compartilhado entre as telas usando o pacote `provider`.
 
 -------------------------------------------------------------------
 🧠 LÓGICA DE IMPLEMENTAÇÃO
 -------------------------------------------------------------------
 
 ### 1. Gerenciamento de Estado (Provider)
 
 ```dart
 class GameProvider extends ChangeNotifier {
   int vitoriasX = 0;
   int vitoriasO = 0;
 
   void addVitoria(String jogador) { ... }
   void resetar() { ... }
 }
 ```
 - O `GameProvider` armazena a pontuação de cada jogador.
 - Quando um jogador vence, `addVitoria` é chamado e `notifyListeners()` atualiza a interface.
 - O ranking e o placar do jogo ouvem esse provider.
 
 ### 2. Lógica do Jogo (`JogoDaVelhaPage`)
 
 - O tabuleiro é uma `List<String>` de 9 posições (vazio = `''`).
 - O jogador atual alterna entre `'X'` e `'O'`.
 - Após cada jogada:
   - Verifica se há um vencedor (função `verificarVitoria`).
   - Verifica se o tabuleiro está cheio (empate).
   - Se houver vitória, o vencedor é registrado no `GameProvider` e um diálogo é exibido.
 - As combinações vencedoras são fixas:
 
 ```dart
 const combinacoes = [
   [0,1,2], [3,4,5], [6,7,8], // linhas
   [0,3,6], [1,4,7], [2,5,8], // colunas
   [0,4,8], [2,4,6]           // diagonais
 ];
 ```
 
 ### 3. Navegação
 
 - **Drawer** e **BottomNavigationBar** levam para as telas `JogoDaVelhaPage`, `RankingPage` e `SobrePage`.
 - O `Navigator.push` é usado para abrir cada página – assim o histórico de navegação é mantido.
 
 ### 4. Ranking e Estatísticas
 
 - São calculadas **porcentagens** de vitória de cada jogador com base no total de partidas.
 - As barras de progresso (`LinearProgressIndicator`) mostram visualmente o aproveitamento.
 - É possível **resetar o ranking** (zerar as vitórias) através de um botão na tela de ranking.
 
 ### 5. Tela Sobre e Contatos
 
 - Utiliza uma foto obtida da URL do GitHub (`https://avatars.githubusercontent.com/u/135072001?v=4`).
 - Exibe nome do desenvolvedor, curso, e‑mail e link do GitHub.
 - Os contatos podem ser copiados para a área de transferência.
 
 -------------------------------------------------------------------
 🎨 ESTILOS E FONTES UTILIZADAS
 -------------------------------------------------------------------
 
 ### Cores e Gradientes
 O app usa **gradientes lineares** para dar um visual moderno:
 - AppBar: `Colors.blue.shade800` → `Colors.blue.shade500`
 - Fundo do corpo: azul claro (`Colors.blue.shade50`) até branco.
 - Cartões de ranking e sobre: gradientes suaves com sombras.
 
 ### Bordas e Sombras
 - Botões e contêineres têm bordas arredondadas (`BorderRadius.circular` entre 12 e 24).
 - Sombras (`BoxShadow`) são aplicadas em cartões para criar profundidade.
 
 ### Fontes de Texto
 O Flutter, por padrão, usa as seguintes famílias tipográficas:
 
 | Plataforma | Fonte Padrão         |
 |------------|----------------------|
 | Android    | Roboto               |
 | iOS        | San Francisco        |
 | Web        | (depende do navegador) |
 
 Nenhuma fonte personalizada foi importada. Os tamanhos variam de `12` a `40`, com pesos como `w500`, `w600` e `bold`.
 
 ### Ícones
 Foram usados ícones da biblioteca padrão do Material Icons (`Icons.games`, `Icons.bar_chart`, `Icons.info`, etc.).
 
 -------------------------------------------------------------------
 👶 GUIA AMIGÁVEL PARA INICIANTES
 -------------------------------------------------------------------
 
 Se você nunca viu Flutter ou programação, este guia vai te ajudar a entender o básico do app.
 
 ### 1. Estrutura de pastas (simplificada)
 - `main.dart` – contém todo o código (uma única página, mas separada em classes).
 - O `void main()` é o ponto de partida. Ele roda o app e insere o `GameProvider` na árvore de widgets.
 
 ### 2. Widgets importantes
 - **StatelessWidget** – não muda depois de criado (ex: `HomePage`, `SobrePage`).
 - **StatefulWidget** – pode mudar ao longo do tempo (ex: `JogoDaVelhaPage`, pois o tabuleiro e o turno mudam).
 
 ### 3. Como a tela de jogo funciona
 - Cada quadrado (casa) é um `GestureDetector` que chama `jogar(i)` quando tocado.
 - `setState()` é chamado para reconstruir o tabuleiro e mostrar o novo símbolo.
 - Se alguém vencer, um `AlertDialog` aparece e oferece "Jogar novamente".
 
 ### 4. Como o placar é compartilhado
 - O `GameProvider` é criado lá no início (`ChangeNotifierProvider`).
 - Dentro de qualquer tela, você pode acessar os dados com `Provider.of<GameProvider>(context)`.
 - Quando alguém vence, `addVitoria` é chamado – **todas as telas** que ouvem o provider são atualizadas automaticamente.
 
 ### 5. Reset do ranking
 - Na tela de ranking, clique em "Resetar Ranking". Um diálogo pede confirmação. Depois de resetar, o placar volta a zero em todas as telas.
 
 ## 📞 Painel de Contatos (personalize com seus dados)

| | |
|--|--|
| **Foto de perfil** | <img src="https://avatars.githubusercontent.com/u/135072001?v=4" width="120" style="border-radius: 50%;" alt="Foto de perfil"> |
| **Nome / Apelido** | Arthur (ImArthz) |
| **E-mail** | [mendoncaoarthur@gmail.com](mailto:mendoncaoarthur@gmail.com) |
| **GitHub** | [github.com/ImArthz](https://github.com/ImArthz) |
| **Curso / Instituição** | Engenharia da Computação – CEFET-MG |

 -------------------------------------------------------------------
 📌 INFORMAÇÕES RELEVANTES ADICIONAIS
 -------------------------------------------------------------------
 
 - **Estado vencedor destacado**: quando alguém vence, as três casas da combinação vencedora ficam com fundo verde claro (`Colors.green.shade100`).
 - **Prevenção de jogadas após fim do jogo**: a função `jogar` verifica se `vencedorCombo != null` e retorna imediatamente.
 - **Responsividade**: o tabuleiro usa `GridView` com `childAspectRatio: 1`, garantindo que as células sejam sempre quadradas.
 - **Snackbars**: usadas para dar feedback ao copiar links ou resetar o ranking.
 - **Tratamento de erro da imagem**: se a foto de perfil não carregar, um ícone de pessoa (`Icons.person`) é exibido.
 
 -------------------------------------------------------------------
 🚀 POSSÍVEIS MELHORIAS (sugestões)
 -------------------------------------------------------------------
 
 1. **Persistência de dados** – salvar as vitórias mesmo após fechar o app (usando `shared_preferences` ou `sqflite`).
 2. **Modo contra o computador** – implementar uma IA simples.
 3. **Mais temas** – permitir trocar entre cores azul/vermelho/verde.
 4. **Animações** – ao marcar uma casa ou ao vencer, uma animação suave.
 5. **Testes unitários** – para a lógica de vitória e estado do provider.
 
 -------------------------------------------------------------------
 ✅ CONCLUSÃO
 -------------------------------------------------------------------
 
 Este aplicativo é um exemplo completo de um jogo interativo com gerenciamento de estado,
 múltiplas telas, estilização moderna e uma tela “Sobre” informativa. Todo o código está
 contido em um único arquivo (`main.dart`) para facilitar o estudo e a modificação.
 
 Divirta-se jogando e aprendendo! Se tiver dúvidas, consulte o painel de contatos acima

 

# **Documentação gerada a partir do código-fonte em março de 2026.**
