import time
import random
import tracemalloc
import csv
import sys
import math

# Aumentar limite de recursão para árvores desbalanceadas
sys.setrecursionlimit(20000)

# =============================================================================
# 1. SPLAY TREE
# =============================================================================
class SplayNode:
    def __init__(self, key):
        self.key = key
        self.left = None
        self.right = None

class SplayTree:
    def __init__(self):
        self.root = None

    def _rotate_right(self, x):
        y = x.left
        x.left = y.right
        y.right = x
        return y

    def _rotate_left(self, x):
        y = x.right
        x.right = y.left
        y.left = x
        return y

    def _splay(self, root, key):
        if root is None or root.key == key:
            return root
        if key < root.key:
            if root.left is None: return root
            if key < root.left.key:
                root.left.left = self._splay(root.left.left, key)
                root = self._rotate_right(root)
            elif key > root.left.key:
                root.left.right = self._splay(root.left.right, key)
                if root.left.right is not None:
                    root.left = self._rotate_left(root.left)
            return root if root.left is None else self._rotate_right(root)
        else:
            if root.right is None: return root
            if key > root.right.key:
                root.right.right = self._splay(root.right.right, key)
                root = self._rotate_left(root)
            elif key < root.right.key:
                root.right.left = self._splay(root.right.left, key)
                if root.right.left is not None:
                    root.right = self._rotate_right(root.right)
            return root if root.right is None else self._rotate_left(root)

    def insert(self, key):
        if self.root is None:
            self.root = SplayNode(key)
            return
        self.root = self._splay(self.root, key)
        if self.root.key == key: return
        n = SplayNode(key)
        if key < self.root.key:
            n.right = self.root
            n.left = self.root.left
            self.root.left = None
        else:
            n.left = self.root
            n.right = self.root.right
            self.root.right = None
        self.root = n

    def search(self, key):
        self.root = self._splay(self.root, key)
        return self.root is not None and self.root.key == key

# =============================================================================
# 2. TREAP
# =============================================================================
class TreapNode:
    def __init__(self, key):
        self.key = key
        self.priority = random.random()
        self.left = None
        self.right = None

class Treap:
    def __init__(self):
        self.root = None

    def _rotate_right(self, y):
        x = y.left
        y.left = x.right
        x.right = y
        return x

    def _rotate_left(self, x):
        y = x.right
        x.right = y.left
        y.left = x
        return y

    def insert(self, key):
        self.root = self._insert_rec(self.root, key)

    def _insert_rec(self, node, key):
        if node is None: return TreapNode(key)
        if key == node.key: return node
        if key < node.key:
            node.left = self._insert_rec(node.left, key)
            if node.left.priority > node.priority:
                node = self._rotate_right(node)
        else:
            node.right = self._insert_rec(node.right, key)
            if node.right.priority > node.priority:
                node = self._rotate_left(node)
        return node

    def search(self, key):
        curr = self.root
        while curr:
            if key == curr.key: return True
            curr = curr.left if key < curr.key else curr.right
        return False

# =============================================================================
# 3. TRIE
# =============================================================================
class TrieNode:
    def __init__(self):
        self.children = {}
        self.is_end = False

class Trie:
    def __init__(self):
        self.root = TrieNode()

    def insert(self, word):
        node = self.root
        for char in word:
            if char not in node.children:
                node.children[char] = TrieNode()
            node = node.children[char]
        node.is_end = True

    def search(self, word):
        node = self.root
        for char in word:
            if char not in node.children:
                return False
            node = node.children[char]
        return node.is_end

# =============================================================================
# 4. PATRICIA TREE (Radix Tree Simples para Benchmark)
# =============================================================================
class PatriciaNode:
    def __init__(self, label=""):
        self.label = label
        self.children = {}
        self.is_end = False

class PatriciaTree:
    def __init__(self):
        self.root = PatriciaNode()

    def insert(self, word):
        self._insert_rec(self.root, word)

    def _insert_rec(self, node, word):
        if not word: return
        for key, child in list(node.children.items()):
            common_len = 0
            for c1, c2 in zip(child.label, word):
                if c1 == c2: common_len += 1
                else: break
            
            if common_len > 0:
                if common_len == len(child.label):
                    if common_len == len(word):
                        child.is_end = True
                    else:
                        self._insert_rec(child, word[common_len:])
                    return
                # Split node
                split_node = PatriciaNode(child.label[common_len:])
                split_node.is_end = child.is_end
                split_node.children = child.children
                
                child.label = child.label[:common_len]
                child.children = {split_node.label[0]: split_node}
                
                if common_len == len(word):
                    child.is_end = True
                else:
                    new_node = PatriciaNode(word[common_len:])
                    new_node.is_end = True
                    child.children[new_node.label[0]] = new_node
                    child.is_end = False
                return
        
        new_node = PatriciaNode(word)
        new_node.is_end = True
        node.children[word[0]] = new_node

    def search(self, word):
        return self._search_rec(self.root, word)

    def _search_rec(self, node, word):
        if not word: return node.is_end
        for child in node.children.values():
            common_len = 0
            for c1, c2 in zip(child.label, word):
                if c1 == c2: common_len += 1
                else: break
            if common_len == len(child.label):
                if common_len == len(word): return child.is_end
                return self._search_rec(child, word[common_len:])
        return False

# =============================================================================
# 5. KD-TREE (2D)
# =============================================================================
class KDNode:
    def __init__(self, point, axis):
        self.point = point
        self.axis = axis
        self.left = None
        self.right = None

class KDTree:
    def __init__(self):
        self.root = None

    def insert(self, point):
        self.root = self._insert_rec(self.root, point, 0)

    def _insert_rec(self, node, point, depth):
        if node is None:
            return KDNode(point, depth % 2)
        if node.point == point: return node
        axis = depth % 2
        if point[axis] < node.point[axis]:
            node.left = self._insert_rec(node.left, point, depth + 1)
        else:
            node.right = self._insert_rec(node.right, point, depth + 1)
        return node

    def search(self, point):
        return self._search_rec(self.root, point, 0)

    def _search_rec(self, node, point, depth):
        if node is None: return False
        if node.point == point: return True
        axis = depth % 2
        if point[axis] < node.point[axis]:
            return self._search_rec(node.left, point, depth + 1)
        else:
            return self._search_rec(node.right, point, depth + 1)

# =============================================================================
# BENCHMARK SUITE
# =============================================================================

def generate_datasets(size, ds_type, is_string=False, is_2d=False):
    if is_2d:
        if ds_type == "random": return [(random.random()*100, random.random()*100) for _ in range(size)]
        elif ds_type == "sorted": return [(float(i), float(i)) for i in range(size)]
        elif ds_type == "skewed": return [(float(i), random.random()*10) for i in range(size)]
    
    if is_string:
        if ds_type == "random": return [str(random.randint(100000, 999999)) + str(i) for i in range(size)]
        elif ds_type == "sorted": return [f"prefix{i:06d}" for i in range(size)]
        elif ds_type == "skewed": return [f"A{i}" for i in range(size)] # all share same first char
        
    # Numeric
    if ds_type == "random": 
        data = list(range(size))
        random.shuffle(data)
        return data
    elif ds_type == "sorted": return list(range(size))
    elif ds_type == "skewed": return [1]*int(size*0.8) + list(range(int(size*0.2)))

def measure_performance(tree, data_insert, data_search):
    # Memória
    tracemalloc.start()
    
    # Insert Time
    t0 = time.perf_counter()
    for item in data_insert:
        tree.insert(item)
    t_insert = time.perf_counter() - t0
    
    # Peak Memory
    current, peak = tracemalloc.get_traced_memory()
    tracemalloc.stop()
    mem_kb = peak / 1024.0

    # Search Time
    t0 = time.perf_counter()
    for item in data_search:
        tree.search(item)
    t_search = time.perf_counter() - t0
    
    return t_insert, t_search, mem_kb

def run_benchmark():
    sizes = [100, 500, 1000, 2000, 5000] # Tamanhos menores para rodar instantâneo
    distributions = ["random", "sorted", "skewed"]
    
    results = []
    
    print("Iniciando Benchmark...", flush=True)
    for size in sizes:
        for dist in distributions:
            print(f"Testando N={size}, Dist={dist}...", flush=True)
            
            # Dados
            num_data = generate_datasets(size, dist)
            str_data = generate_datasets(size, dist, is_string=True)
            pt_data = generate_datasets(size, dist, is_2d=True)
            
            # Buscas mistas (50% existem, 50% não existem)
            num_search = num_data[:size//2] + [-1]*(size//2)
            str_search = str_data[:size//2] + ["NOTFOUND"]*(size//2)
            pt_search = pt_data[:size//2] + [(-1.0, -1.0)]*(size//2)

            # Splay
            t_ins, t_sch, mem = measure_performance(SplayTree(), num_data, num_search)
            results.append(["Splay", size, dist, t_ins, t_sch, mem])
            
            # Treap
            t_ins, t_sch, mem = measure_performance(Treap(), num_data, num_search)
            results.append(["Treap", size, dist, t_ins, t_sch, mem])
            
            # Trie
            t_ins, t_sch, mem = measure_performance(Trie(), str_data, str_search)
            results.append(["Trie", size, dist, t_ins, t_sch, mem])
            
            # Patricia
            t_ins, t_sch, mem = measure_performance(PatriciaTree(), str_data, str_search)
            results.append(["Patricia", size, dist, t_ins, t_sch, mem])
            
            # KD-Tree
            t_ins, t_sch, mem = measure_performance(KDTree(), pt_data, pt_search)
            results.append(["KDTree", size, dist, t_ins, t_sch, mem])

    # Salvar CSV
    with open('benchmark_results.csv', 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(["Structure", "Size", "Distribution", "InsertTime(s)", "SearchTime(s)", "Memory(KB)"])
        writer.writerows(results)
    
    print("Benchmark concluído! Salvo em benchmark_results.csv", flush=True)

if __name__ == "__main__":
    run_benchmark()
