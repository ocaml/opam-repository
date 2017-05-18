try:
    m = rdkit.Chem.MolFromSmiles('O=C=O')
    print "python-rdkit OK"
except:
    print "python-rdkit KO"
    exit(1)
