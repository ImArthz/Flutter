import os

path = r'C:\Users\Usuario\Desktop\Projeto_Arvores_Avancadas\projeto_arvores_avancadas\artigo_academico\artigo_arvores.tex'

with open(path, 'rb') as f:
    raw = f.read()

# Let's decode with cp1252 and encode with utf-8
try:
    # the string might be utf-8 but broken?
    # Actually, windows powershell probably wrote it in whatever the default is.
    text = raw.decode('windows-1252')
except Exception as e:
    text = raw.decode('utf-8', errors='replace')

# Wait, if the original python output it right, but then powershell appended something...
# Let's just fix the specific words using regex.
import re
text = text.replace('acadGmico', 'acadêmico')
text = text.replace('din?mica', 'dinâmica')
text = text.replace('lG', 'lê')
text = text.replace('dicionorios', 'dicionários')
text = text.replace('Espaamento', 'Espaçamento')
text = text.replace('operauo', 'operação')
text = text.replace('orvores', 'árvores')
text = text.replace('orvore', 'árvore')
text = text.replace('Informaes', 'Informações')
text = text.replace('informaes', 'informações')
text = text.replace('Ps-Graduauo', 'Pós-Graduação')
text = text.replace('Conclusuo', 'Conclusão')
text = text.replace('Ps', 'Pós')
text = text.replace('ns', 'nós')
text = text.replace('n', 'nó')
text = text.replace('nGvel', 'nível')
text = text.replace('prprio', 'próprio')
text = text.replace('avaliauo', 'avaliação')
text = text.replace('padruo', 'padrão')
text = text.replace('groficos', 'gráficos')
text = text.replace('mGtodos', 'métodos')
text = text.replace('tGcnicas', 'técnicas')
text = text.replace('referGncias', 'referências')
text = text.replace('ReferGncias', 'Referências')
text = text.replace('Pgina', 'Página')
text = text.replace('So', 'São')
text = text.replace('No', 'Não')

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)
