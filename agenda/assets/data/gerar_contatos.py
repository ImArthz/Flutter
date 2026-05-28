import json
import random
import string

def gerar_seed():
    """Gera uma seed aleatória de 10 caracteres."""
    return ''.join(random.choices(string.ascii_lowercase + string.digits, k=10))

def main():
    random.seed()  # usa horário do sistema

    primeiros_nomes = [
        'João', 'Maria', 'Pedro', 'Ana', 'Carlos', 'Fernanda', 'Rafaela',
        'Lucas', 'Juliana', 'Bruno', 'Camila', 'Gustavo', 'Amanda',
        'Ricardo', 'Patrícia', 'Felipe', 'Letícia', 'Thiago', 'Vanessa',
        'Marcelo', 'Bianca', 'Daniel', 'Carolina', 'Eduardo', 'Natália',
        'Vinícius', 'Isabela', 'Leonardo', 'Larissa', 'Hugo', 'Sofia',
        'Henrique', 'Gabriela', 'Arthur', 'Manuela', 'Davi', 'Lorena',
        'Cauã', 'Heloísa', 'Enzo', 'Valentina', 'Benício', 'Clara',
        'Emanuelly', 'Dante', 'Maitê', 'José', 'Antônio', 'Francisca'
    ]
    sobrenomes = [
        'Silva', 'Souza', 'Santos', 'Oliveira', 'Costa', 'Lima',
        'Pereira', 'Alves', 'Ferreira', 'Rodrigues', 'Martins',
        'Barbosa', 'Gonçalves', 'Lopes', 'Mendes', 'Araújo',
        'Carvalho', 'Nunes', 'Ribeiro', 'Teixeira', 'Moreira',
        'Cardoso', 'Neves', 'Pires', 'Campos', 'Rocha', 'Borges',
        'Vieira', 'Peixoto', 'Freitas', 'Tavares', 'Moraes',
        'Santana', 'Cunha', 'Nascimento', 'Nogueira', 'Monteiro',
        'Meireles', 'Barros', 'Farias', 'Duarte', 'Leão',
        'Vasconcelos', 'Figueiredo', 'Brito'
    ]
    logradouros = [
        'Rua das Flores', 'Av. Brasil', 'Rua Sete de Setembro',
        'Av. Paulista', 'Rua XV de Novembro', 'Rua da Consolação',
        'Av. Ipiranga', 'Rua Augusta', 'Rua Oscar Freire',
        'Alameda Santos', 'Praça da Sé', 'Rua dos Pinheiros',
        'Av. Rebouças', 'Rua Teodoro Sampaio', 'Rua Cardoso de Almeida'
    ]
    observacoes = [
        'Cliente desde 2020', 'Prefere contato por e-mail', 'VIP',
        'Fornecedor parceiro', 'Não atende depois das 18h',
        'Entregar no período da manhã', 'Segunda via do boleto',
        'Assinatura premium', 'Indicação do João',
        'Ligar apenas em caso de urgência', 'Enviar catálogo atualizado',
        'Revisão de contrato', 'Primeiro contato em fevereiro/23',
        'Atendimento prioritário', 'Desconto especial aplicado'
    ]

    # Gera todas as combinações possíveis de nome + sobrenome (49 * 45 = 2205)
    todas_combinacoes = []
    for p in primeiros_nomes:
        for s in sobrenomes:
            todas_combinacoes.append(f'{p} {s}')
    random.shuffle(todas_combinacoes)
    nomes_unicos = todas_combinacoes[:200]  # pega os primeiros 200 embaralhados

    contatos = []
    print('🔧 Gerando 200 contatos...')
    for i in range(200):
        id_str = str(i + 1)
        nome = nomes_unicos[i]

        ddd = f'{random.randint(11, 99):02d}'
        parte1 = random.randint(1000, 9999)
        parte2 = random.randint(1000, 9999)
        telefone = f'({ddd}) {parte1}-{parte2}'

        rua = random.choice(logradouros)
        numero = random.randint(1, 999)
        endereco = f'{rua}, {numero}'

        seed = gerar_seed()
        foto = f'https://picsum.photos/seed/{seed}/200/200'

        obs = random.choice(observacoes)

        contato = {
            'id': id_str,
            'nome': nome,
            'telefone': telefone,
            'endereco': endereco,
            'fotoPerfil': foto,
            'observacao': obs
        }
        contatos.append(contato)

        if (i + 1) % 20 == 0:
            print(f'✔️  {i + 1}/200 contatos gerados')

    with open('contatos.json', 'w', encoding='utf-8') as f:
        json.dump(contatos, f, indent=2, ensure_ascii=False)
    print('✅ Arquivo "contatos.json" criado com sucesso!')

if __name__ == '__main__':
    main()