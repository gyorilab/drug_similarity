# -*- coding: utf-8 -*-

"""
The INDRA2Vec embeddings were done on the INDRA database dump with a minimum belief cutoff of 0.2
using the node2vec model. The similarities are calculated with the cosine metric to match the
way the underlying word2vec model was trained.
"""

import gzip
import pathlib
from itertools import combinations

from scipy.spatial.distance import pdist

from indra2vec import Model

HERE = pathlib.Path(__file__).parent.resolve()
PATH = HERE.joinpath('similarity.tsv.gz')

CHEMICAL_PREFIXES = [
    'CHEBML',
    'CHEBI',
    'DRUGBANK',
    'PUBCHEM',
]


def main():
    # Load the default model, which is trained at belief >= 0.20 from
    # the INDRA2Vec repo. This code isn't public yet and neither is the
    # full INDRA db on which it was trained, so just ask if you want to
    # take a look or know more.
    model = Model.load_default()

    # extract all chemical CURIEs from the model based on prefix. This might
    # lose a few MeSH chemicals, but we'll accept that for simplicity's sake.
    curies = sorted([
        curie
        for curie in model.vocab
        if any(curie.startswith(prefix) for prefix in CHEMICAL_PREFIXES)
    ])

    # only consider the vectors corresponding to all chemicals
    vectors = model[curies]

    # calculate the full pairwise distance, returning a condensed distance matrix
    distances = pdist(vectors, metric='cosine')

    # This is about ~7GB unzipped so this is necessary
    with gzip.open(PATH, 'wt') as file:
        for (left, right), distance in zip(combinations(curies, 2), distances):
            print(left, right, round(distance, 3), sep='\t', file=file)


if __name__ == '__main__':
    main()
