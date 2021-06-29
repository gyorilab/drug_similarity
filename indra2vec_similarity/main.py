# -*- coding: utf-8 -*-

"""
The INDRA2Vec embeddings were done on the INDRA database dump with a minimum belief cutoff of 0.2
using the node2vec model. The similarities are calculated with the cosine metric to match the
way the underlying word2vec model was trained.
"""

import pathlib
from typing import Optional

import click

HERE = pathlib.Path(__file__).parent.resolve()
SIM_PATH = HERE.joinpath("similarity.tsv.gz")
HIST_PATH = HERE.joinpath("similarity_hist.svg")
DD_PATH = HERE.joinpath("degree_distribution.svg")

#: See https://www.synapse.org/#!Synapse:syn25928953/
SYNAPSE_PROJECT_ID = "syn25928953"

CHEMICAL_PREFIXES = [
    "CHEMBL",
    "CHEBI",
    "DRUGBANK",
    "PUBCHEM",
]


@click.group()
def main():
    """Run the INDRA2Vec code."""


@main.command()
@click.option(
    "--cutoff",
    type=float,
    help="Apply a minimum cosine similarity cutoff.",
)
@click.option(
    "--belief",
    default="20",
    type=str,
    show_default=True,
    help="Minimum belief cutoff percent",
)
@click.option(
    "--precision",
    type=int,
    default=3,
    show_default=True,
    help="Precision of similarities",
)
def calculate(cutoff: Optional[float], belief: str, precision: int):
    import gzip
    from collections import Counter
    from itertools import combinations

    import matplotlib.pyplot as plt
    import networkx as nx
    import seaborn as sns
    from scipy.spatial.distance import pdist
    from tabulate import tabulate
    from tqdm import tqdm

    from indra2vec import Model

    # Load the default model, which is trained at belief >= 0.20 from
    # the INDRA2Vec repo. This code isn't public yet and neither is the
    # full INDRA db on which it was trained, so just ask if you want to
    # take a look or know more.
    model = Model.load_default("embeddings", "full", belief)

    # extract all chemical CURIEs from the model based on prefix. This might
    # lose a few MeSH chemicals, but we'll accept that for simplicity's sake.
    curies = sorted(
        [
            curie
            for curie in model.vocab
            if any(curie.startswith(prefix) for prefix in CHEMICAL_PREFIXES)
        ]
    )

    print(f"There are {len(curies)} chemicals")
    counter = Counter(curie.split(":")[0] for curie in curies)
    print(tabulate(counter.most_common(), headers=["Prefix", "Count"]))

    # only consider the vectors corresponding to all chemicals
    vectors = model[curies]

    # calculate the full pairwise distance, returning a condensed distance matrix,
    # then convert back to similarities so 1.0 means they are basically the same
    # and 0.0 means very different.
    similarities = 1 - pdist(vectors, metric="cosine")

    ch = sns.displot(similarities, bins=100)
    ch.set(xlabel="Cosine Similarity")
    ch.savefig(HIST_PATH)
    plt.close(ch.fig)

    # Match combinations and unpack tuples
    it = (
        (left, right, round(similarity, precision))
        for (left, right), similarity in zip(
            combinations(curies, 2), tqdm(similarities, unit_scale=True)
        )
    )

    # Apply a minimum similarity cutoff, if given
    if cutoff is not None:
        it = (
            (left, right, similarity)
            for left, right, similarity in it
            if cutoff < similarity
        )

    # Maintain a graph data structure for checking degrees
    graph = nx.Graph()

    # This is about ~7GB unzipped so this is necessary
    with gzip.open(SIM_PATH, "wt") as file:
        for left, right, similarity in it:
            print(left, right, similarity, sep="\t", file=file)
            graph.add_edge(left, right, weight=abs(similarity))

    y = sorted((degree for _, degree in graph.degree(weight="weight")), reverse=True)
    x = range(len(y))

    # def exponential(t, a, b):
    #     # for curve fitting of the degree distribution
    #     return a * np.exp(b * t)
    # params, _residuals = scipy.optimize.curve_fit(exponential, x, y, p0=(3.0, -2.0))
    # print(params)

    fig, ax = plt.subplots()
    sns.lineplot(x=x, y=y, ax=ax)
    ax.set_yscale("log")
    ax.set_ylabel("Degree")
    ax.set_xlabel("Rank")
    fig.savefig(DD_PATH)
    plt.close(fig)


@main.command()
def upload():
    """Upload to synapse."""
    import synapseclient
    import pystow
    from synapseclient import Project, Folder, File

    syn = synapseclient.Synapse()
    syn.login(
        email=pystow.get_config("synapse", "username"),
        password=pystow.get_config("synapse", "password"),
        apiKey=pystow.get_config("synapse", "api_key"),
    )
    project: Project = syn.get(SYNAPSE_PROJECT_ID)

    data_folder = Folder("indra2vec", parent=project)
    data_folder = syn.store(data_folder)

    test_entity = File(
        SIM_PATH.as_posix(),
        description="INDRA2Vec Chemical Similarities",
        parent=data_folder,
    )
    test_entity = syn.store(test_entity)

    test_entity2 = File(
        HIST_PATH.as_posix(),
        description="INDRA2Vec Chemical Similarity Histogram",
        parent=data_folder,
    )
    test_entity2 = syn.store(test_entity2)

    test_entity3 = File(
        DD_PATH.as_posix(),
        description="INDRA2Vec Chemical Similarity Degree Distribution",
        parent=data_folder,
    )
    test_entity3 = syn.store(test_entity3)


if __name__ == "__main__":
    main()
