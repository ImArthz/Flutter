import os

pt_path = r'C:\Users\Usuario\Desktop\Projeto_Arvores_Avancadas\projeto_arvores_avancadas\artigo_academico\artigo_arvores.tex'
with open(pt_path, 'r', encoding='utf-8') as f:
    pt_content = f.read()

new_section_pt = r'''
\section{Aplicativo Móvel e Simulador Visual}
Com o intuito de apresentar as estruturas de dados avançadas de maneira didática e interativa, um aplicativo móvel completo foi desenvolvido utilizando o framework Flutter e a linguagem Dart. O aplicativo conta com uma arquitetura moderna e fluida, implementando os conceitos de Glassmorphism e tipografia limpa.

Através deste aplicativo, o usuário tem a capacidade de:
\begin{itemize}
    \item \textbf{Visualização Interativa:} Renderização espacial das árvores em um \textit{Canvas} infinito com opções de zoom e pan.
    \item \textbf{Simulação Passo a Passo:} Um módulo assíncrono executa operações de inserção, busca e deleção com um \textit{delay} dinâmico (2 segundos). A tela reage refletindo visualmente as alterações, demonstrando graficamente os balanceamentos probabilísticos e estruturais acontecendo em tempo real.
    \item \textbf{Teoria Integrada:} Telas dedicadas que explicam a lógica matemática por trás das cinco estruturas abordadas no projeto (Splay Tree, Treap, Trie, Patricia Tree e KD-Tree).
\end{itemize}

Todo o código-fonte do aplicativo, bem como da biblioteca desenvolvida contendo as Árvores, encontra-se totalmente aberto para a comunidade e o projeto completo pode ser acessado diretamente através do repositório no GitHub: \\ \url{https://github.com/ImArthz/Flutter/tree/master/projeto_arvores_avancadas}.
'''

# Find the insertion point (before \section{Análise Teórica de Complexidade})
pt_content = pt_content.replace(r'\section{Análise Teórica de Complexidade}', new_section_pt + '\n' + r'\section{Análise Teórica de Complexidade}')

with open(pt_path, 'w', encoding='utf-8') as f:
    f.write(pt_content)


en_path = r'C:\Users\Usuario\Desktop\Projeto_Arvores_Avancadas\projeto_arvores_avancadas\artigo_academico\article_trees.tex'
with open(en_path, 'r', encoding='utf-8') as f:
    en_content = f.read()

new_section_en = r'''
\section{Mobile Application and Visual Simulator}
In order to present the advanced data structures in a didactic and interactive manner, a comprehensive mobile application was developed using the Flutter framework and the Dart programming language. The app features a modern and fluid architecture, implementing Glassmorphism concepts and clean typography.

Through this application, the user has the ability to:
\begin{itemize}
    \item \textbf{Interactive Visualization:} Spatial rendering of the trees on an infinite \textit{Canvas} with zoom and pan capabilities.
    \item \textbf{Step-by-step Simulation:} An asynchronous module executes insertion, search, and deletion operations with a dynamic delay (2 seconds). The screen reacts by visually reflecting the changes, graphically demonstrating the probabilistic and structural balancing happening in real time.
    \item \textbf{Integrated Theory:} Dedicated screens that explain the mathematical logic behind the five structures covered in the project (Splay Tree, Treap, Trie, Patricia Tree, and KD-Tree).
\end{itemize}

The complete source code of the application, as well as the developed library containing the Trees, is fully open to the community. The entire project can be accessed directly through the GitHub repository: \\ \url{https://github.com/ImArthz/Flutter/tree/master/projeto_arvores_avancadas}.
'''

# Find the insertion point
en_content = en_content.replace(r'\section{Theoretical Complexity Analysis}', new_section_en + '\n' + r'\section{Theoretical Complexity Analysis}')

with open(en_path, 'w', encoding='utf-8') as f:
    f.write(en_content)

print("Files modified successfully.")