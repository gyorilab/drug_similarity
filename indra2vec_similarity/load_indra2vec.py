# -*- coding: utf-8 -*-

"""
The INDRA2Vec embeddings were done on the INDRA database dump with a minimum belief cutoff of 0.2
using the node2vec model. The similarities are calculated with the cosine metric to match the
way the underlying word2vec model was trained.
"""

import gzip
import pathlib
from itertools import combinations
from typing import Optional

import click
from scipy.spatial.distance import pdist
from tqdm import tqdm

from indra2vec import Model

HERE = pathlib.Path(__file__).parent.resolve()
PATH = HERE.joinpath('similarity.tsv.gz')

CHEMICAL_PREFIXES = [
    'CHEBML',
    'CHEBI',
    'DRUGBANK',
    'PUBCHEM',
]


@click.command()
@click.option('--cutoff', type=float, help='Apply a minimum cosine similarity cutoff.')
@click.option('--precision', type=int, default=3, show_default=True, help='Precision of similarities')
def main(cutoff: Optional[float], precision: int):
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

    # calculate the full pairwise distance, returning a condensed distance matrix,
    # then convert back to similarities so 1.0 means they are basically the same
    # and 0.0 means very different.
    similarities = 1 - pdist(vectors, metric='cosine')

    # Match combinations and unpack tuples
    it = (
        (left, right, round(similarity, precision))
        for (left, right), similarity in zip(combinations(curies, 2), similarities)
    )

    # Apply a minimum similarity cutoff, if given
    if cutoff is not None:
        it = (
            (left, right, similarity)
            for left, right, similarity in it
            if cutoff < similarity
        )

    # This is about ~7GB unzipped so this is necessary
    with gzip.open(PATH, 'wt') as file:
        for left, right, similarity in tqdm(it, desc='writing'):
            print(left, right, similarity, sep='\t', file=file)


if __name__ == '__main__':
    main()
