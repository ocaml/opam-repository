#!/usr/bin/env python3

import rdkit
from rdkit import Chem

morphine_cano_smi = 'CN1CC[C@]23c4c5ccc(O)c4O[C@H]2[C@@H](O)C=C[C@H]3[C@H]1C5'
mol = Chem.MolFromSmiles(morphine_cano_smi)
assert(morphine_cano_smi == Chem.MolToSmiles(mol))
print("rdkit python test OK")
