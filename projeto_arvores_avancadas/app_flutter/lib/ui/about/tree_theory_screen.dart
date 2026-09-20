import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class TreeTheoryScreen extends StatelessWidget {
  const TreeTheoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teoria das Árvores')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildTheoryCard(
            title: 'Splay Tree',
            color: AppColors.splayNode,
            content: 'Diferente das árvores AVL e Rubro-Negra, a Splay Tree é uma Árvore Binária de Busca auto-ajustável que não guarda fatores de balanceamento nos nós. Seu mecanismo central é o Splaying: toda vez que um nó é acessado (busca, inserção ou até tentativas falhas), ele é "puxado" para a raiz através de rotações duplas e simples (Zig, Zig-Zig, Zig-Zag).\n\n'
                'Isso traz um tempo amortizado de O(log N), sendo excelente para "efeitos de cache", onde dados acessados recentemente são encontrados muito mais rápido em operações futuras.',
          ),
          const SizedBox(height: 16),
          _buildTheoryCard(
            title: 'Treap (Tree + Heap)',
            color: AppColors.treapNode,
            content: 'A Treap une as regras de uma Árvore Binária de Busca com as de um Max-Heap (ou Min-Heap). A ideia principal é probabilística: cada nova chave inserida recebe uma prioridade completamente aleatória.\n\n'
                'Pela regra BST: filhos à esquerda são menores, à direita maiores. Pela regra Heap: a prioridade do pai é sempre maior que a dos filhos. As rotações acontecem para garantir essas duas leis simultaneamente. O balanceamento é probabilístico, garantindo O(log N) no caso médio.',
          ),
          const SizedBox(height: 16),
          _buildTheoryCard(
            title: 'Trie (Digital Tree)',
            color: AppColors.trieNode,
            content: 'A estrutura Trie foge do paradigma de comparações matemáticas entre nós. Em vez disso, a chave (geralmente uma String) é fragmentada, e cada caractere vira uma aresta em um dicionário (HashMap) ou Array.\n\n'
                'A complexidade cai de O(log N) para O(M), onde M é o tamanho da string. A grande desvantagem é o alto consumo de memória, pois prefixos não compartilhados criam nós vazios em abundância.',
          ),
          const SizedBox(height: 16),
          _buildTheoryCard(
            title: 'Patricia Tree (Radix Compacta)',
            color: AppColors.patriciaNode,
            content: 'O acrônimo PATRICIA (Practical Algorithm to Retrieve Information Coded in Alphanumeric) resolve a fragmentação de memória da Trie padrão. A árvore comprime o grafo: se um nó tem apenas um caminho/filho único, os caracteres desse caminho são concatenados em um único rótulo (label).\n\n'
                'Com isso, o tempo de busca se mantém espetacular O(M), mas o gasto de memória RAM desaba, otimizando o armazenamento e tornando a árvore aplicável em roteadores e bancos de dados densos.',
          ),
          const SizedBox(height: 16),
          _buildTheoryCard(
            title: 'KD-Tree (K-Dimensional)',
            color: AppColors.kdNode,
            content: 'Base da computação gráfica e de sistemas geográficos (GIS). A KD-Tree estende a busca para múltiplas dimensões (no caso deste app, 2D: X e Y).\n\n'
                'Ao inserir um ponto, o nível da árvore define qual eixo será testado. Nos níveis pares (0, 2, 4), comparamos a coordenada X. Nos ímpares (1, 3, 5), comparamos a coordenada Y. Isso subdivide recursivamente o plano Euclidiano em quadrantes cada vez menores, acelerando muito a busca por vizinhos mais próximos (Nearest Neighbor).',
          ),
        ],
      ),
    );
  }

  Widget _buildTheoryCard({required String title, required Color color, required String content}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withOpacity(0.5), width: 2),
      ),
      child: ExpansionTile(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color)),
        leading: Icon(Icons.account_tree, color: color),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        children: [
          Text(content, style: const TextStyle(fontSize: 16, height: 1.5, color: AppColors.textPrimary), textAlign: TextAlign.justify),
        ],
      ),
    );
  }
}
