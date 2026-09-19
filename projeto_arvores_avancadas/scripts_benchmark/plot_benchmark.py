import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

def plot_benchmark():
    # Read CSV
    df = pd.read_csv('benchmark_results.csv')
    
    # Setup styles
    sns.set_theme(style="whitegrid")
    
    # 1. Gráfico: Tempo de Inserção vs Tamanho (Random)
    plt.figure(figsize=(10, 6))
    sns.lineplot(data=df[df['Distribution'] == 'random'], x='Size', y='InsertTime(s)', hue='Structure', marker='o')
    plt.title('Tempo de Inserção vs Tamanho da Entrada (Dados Aleatórios)')
    plt.ylabel('Tempo (Segundos)')
    plt.xlabel('Tamanho da Entrada (N)')
    plt.tight_layout()
    plt.savefig('insert_time_random.png', dpi=300)
    plt.close()

    # 2. Gráfico: Tempo de Busca vs Tamanho (Random)
    plt.figure(figsize=(10, 6))
    sns.lineplot(data=df[df['Distribution'] == 'random'], x='Size', y='SearchTime(s)', hue='Structure', marker='o')
    plt.title('Tempo de Busca vs Tamanho da Entrada (Dados Aleatórios)')
    plt.ylabel('Tempo (Segundos)')
    plt.xlabel('Tamanho da Entrada (N)')
    plt.tight_layout()
    plt.savefig('search_time_random.png', dpi=300)
    plt.close()

    # 3. Gráfico: Memória vs Tamanho (Random)
    plt.figure(figsize=(10, 6))
    sns.lineplot(data=df[df['Distribution'] == 'random'], x='Size', y='Memory(KB)', hue='Structure', marker='o')
    plt.title('Consumo de Memória vs Tamanho da Entrada (Dados Aleatórios)')
    plt.ylabel('Memória de Pico (KB)')
    plt.xlabel('Tamanho da Entrada (N)')
    plt.tight_layout()
    plt.savefig('memory_random.png', dpi=300)
    plt.close()
    
    # 4. Gráfico de Barras: Impacto de Pior Caso (N=20000, Inserção)
    plt.figure(figsize=(12, 6))
    df_worst = df[df['Size'] == 20000]
    sns.barplot(data=df_worst, x='Structure', y='InsertTime(s)', hue='Distribution')
    plt.title('Sensibilidade da Inserção por Distribuição dos Dados (N=20000)')
    plt.ylabel('Tempo de Inserção (Segundos)')
    plt.xlabel('Estrutura de Dados')
    plt.tight_layout()
    plt.savefig('distribution_impact.png', dpi=300)
    plt.close()

    print("Gráficos gerados com sucesso! (PNGs salvos no diretório)")

if __name__ == "__main__":
    plot_benchmark()
