#!/usr/bin/env python

import os
import sys
import pandas as pd
import numpy as np
import tempfile
import itertools
from copy import copy

sys.path.append("WGSUniFrac")
from wgsunifrac import *

nodes_file = "augmented/fungiaug_nodes.dmp"
names_file = "augmented/fungiaug_names.dmp"
acc2taxid_file = "augmented/fungiaug_accession2taxid.dmp"

with open(acc2taxid_file, 'r') as f:
    line_gen = (line.rstrip("\n").split() for line in f)
    acc2taxid = dict((acc,int(taxid)) for acc,taxid in line_gen)
    assert(len(acc2taxid))

kept_levels = ["no rank","superkingdom", "phylum", "class",
               "order", "family", "genus", "species", "strain", "acc"]

with open(nodes_file, 'r') as f:
    line_gen = (line.rstrip("\n").split("\t|\t")[:3] for line in f)
    get_parent = dict((int(a[0]),(int(a[1]), a[2])) for a in line_gen)
    assert(len(get_parent))

with open(names_file, 'r') as f:
    line_gen = (line.rstrip().rstrip("|").rstrip().split("\t|\t")[:4] for line in f)
    get_name = dict((int(a[0]),a[1]) for a in line_gen if a[3] == "scientific name")
    assert(len(get_name))

def get_taxon_path(taxid):
    taxid_list = []
    rank_list = []

    while taxid != 1:
        parent,rank = get_parent[taxid]
        taxid_list.append(taxid)
        rank_list.append(rank)
        taxid = parent

    taxid_list.append(1)
    rank_list.append("no rank")

    return [taxid_list, rank_list]

kept_levels = {
    "no rank":0,
    "superkingdom":0,
    "phylum":0,
    "class":0,
    "order":0,
    "family":0,
    "genus":0,
    "species":0,
    "strain":0,
    "acc":0
}

def generate_profile(header, taxids):
    assert(np.isclose(sum(taxids.values()), 1.0))
    tax_paths = [get_taxon_path(taxid) for taxid,count in taxids.items()]
    all_levels = kept_levels.keys()
    for taxid_path,taxlevel_path in tax_paths:
        cur_levels = set(taxlevel_path)
        all_levels = all_levels & cur_levels

    cur_kept_levels = dict(a for a in kept_levels.items() if a[0] in all_levels)
    ranks_to_report = "|".join(cur_kept_levels.keys())
    output = [
        "# Taxonomic Profiling Output",
        f'@SampleID: {header}',
        f'@Version:1.0',
        f'@Ranks:{ranks_to_report}',
        '@TaxonomyID: Jan 08 2019',
        '@@TAXID\tRANK\tTAXPATH\tTAXPATHSN\tPERCENTAGE',
    ]
    base_output = len(output)

    rank_count = dict()
    for (taxid_path,taxlevel_path),(taxid,count) in zip(tax_paths,taxids.items()):
        added = set()
        assert(count <= 1.0)
        assert(count > 0)
        taxnames = [get_name[taxid] for taxid in taxid_path]
        for i,(cur_taxid,cur_rank) in enumerate(zip(taxid_path,taxlevel_path)):
            if cur_rank not in cur_kept_levels or (cur_rank == "no rank" and i + 1 != len(taxid_path)):
                continue

            assert(cur_rank not in added)
            added.add(cur_rank)

            if cur_rank not in rank_count:
                rank_count[cur_rank] = dict()

            if cur_taxid not in rank_count[cur_rank]:
                rank_count[cur_rank][cur_taxid] = [
                    count,
                    "|".join(str(t) for t in taxid_path[i:][::-1]),
                    "|".join(n for n in taxnames[i:][::-1]),
                ]
            else:
                rank_count[cur_rank][cur_taxid][0] += count

    for rank in kept_levels:
        if rank not in rank_count:
            continue

        cursum = sum(count for count,taxidpath,namepath in rank_count[rank].values())
        assert(np.isclose(cursum, 1.0))
        for taxid,(count,taxidpath,namepath) in rank_count[rank].items():
            output.append(f'{taxid}\t{rank}\t{taxidpath}\t{namepath}\t{count/cursum*100.0}')

    assert(len(output) > base_output)
    return output,cur_kept_levels

def encode_profile(output, alpha):
    f = tempfile.NamedTemporaryFile(mode='w+')
    f.write("\n".join(output))
    f.seek(0)
    name,metadata,profile = open_profile_from_tsv(f.name, False)[0]
    return Profile(sample_metadata=metadata,profile=profile,branch_length_fun=lambda x: x ** alpha)

def profile_dist(f, g):
    (Tint, lint, nodes_in_order, nodes_to_index, P, Q) = f.make_unifrac_input_and_normalize(g)
    (weighted, _) = EMDUnifrac_weighted(Tint, lint, nodes_in_order, P, Q)
    return weighted

k = 31
alpha = -1
with open(sys.argv[1], 'r') as f,open(sys.argv[2], 'r') as g:
    g_iter = enumerate(itertools.zip_longest(*[g]*2))
    df = pd.read_table(f, header=None,
                       names=["read_num", "score", "begin", "end", "labels"])
    df_grouped = df.groupby("read_num")

    for i,(header,cur_read) in g_iter:
        header = header[1:-1]

        readid = header.split("-")[0]
        true_taxid = acc2taxid[readid]
        true_profile,true_cur_kept_levels = generate_profile(header, { true_taxid: 1.0 })
        true_profile_enc = encode_profile(true_profile, alpha)

        cur_read = cur_read[:-1]
        readlen = len(cur_read)
        coverage_label_to_marker = []
        label_to_marker = dict()
        df_group = df_grouped.get_group(i)
        if len(df_group) > 0:
            marker = np.zeros(readlen).astype(bool)
            for row_num,(score,begin,end,labels) in df_group.sort_values(by="score",ascending=False)[["score","begin","end","labels"]].iterrows():
                if marker[begin:end].sum() > 0:
                    continue
                label_marker = np.zeros(readlen).astype(bool)
                label_marker[begin:end] = True
                marker |= label_marker
                for label in (".".join(label.split("/")[-1].split(".")[:2]) for label in labels.split(";")):
                    if label not in label_to_marker:
                        label_to_marker[label] = label_marker
                    else:
                        label_to_marker[label] |= label_marker
                coverage_label_to_marker.append((copy(marker), label_marker, score/readlen, copy(label_to_marker)))
        else:
            label_to_marker["unclassified"] = np.ones(readlen).astype(bool)
            coverage_label_to_marker.append((marker, marker, 0, label_to_marker))

        results = []
        for marker,mask,rel_score,label_to_marker in coverage_label_to_marker:
            counts = np.array([lmarker.sum() for label,lmarker in label_to_marker.items()])
            assert(np.all(counts <= readlen))
            assert(np.all(counts > 0))
            assert(counts.sum() > 0)
            counts = counts.astype(float) / counts.sum()
            assert(np.isclose(counts.sum(), 1.0))
            taxids = [acc2taxid[label] if label != "unclassified" else 1 for label in label_to_marker]
            assert(len(taxids) == len(set(taxids)))
            profile,cur_kept_levels = generate_profile(header, dict(zip(taxids, counts)))

            last = "root"
            last_named = "root"
            last_taxid = 1

            profile_subset = [l for l in profile if l[0] != "@" and l[0] != "#" and l.split("\t")[1] in true_cur_kept_levels]
            true_profile_subset = [l for l in true_profile if l[0] != "@" and l[0] != "#"]
            for l1,l2 in zip(profile_subset,true_profile_subset):
                if l1 != l2:
                    break
                else:
                    l1 = l1.split("\t")
                    last = l1[1]
                    if l1[1] != "no rank":
                        last_named = l1[1]
                    last_taxid = int(l1[0])

            profile_enc = encode_profile(profile, alpha)
            result = [float(marker.sum())/len(marker),
                      float(mask.sum())/len(mask),
                      last_taxid,
                      profile_dist(profile_enc, true_profile_enc),
                      last_named,
                      last,
                      rel_score]
            results.append(",".join(str(a) for a in result))
        results = ";".join(results)
        print(f'{i}\t{readid}\t{true_taxid}\t{header}\t{last_taxid}\t{results}')
