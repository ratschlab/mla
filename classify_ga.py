#!/usr/bin/env python

import os
import sys
import pandas as pd
import numpy as np
import itertools
from copy import copy

with open(sys.argv[1], 'r') as f,open(sys.argv[2], 'r') as g:
    g_iter = itertools.zip_longest(*[g]*2)

    ga_data = [line.rstrip().split("\t") for line in f.readlines()]
    f_grouped = itertools.groupby(ga_data, lambda x:x[0])

    header = 0

    for read_id,(cur_header, cur_read) in enumerate(g_iter):
        cur_header = cur_header[1:-1]
        readid = cur_header.split("-")[0]
        if header == 0:
            try:
                header, score_data = next(f_grouped)
            except StopIteration:
                pass

        results = []
        if header == cur_header:
            rlen = len(cur_read) - 1
            score_data = list(score_data)
            query_reg = [(int(a[2]),int(a[3])) for a in score_data]
            nscores = [-float(a[13].split(":")[-1])/rlen for a in score_data]
            marker = np.zeros(rlen).astype(bool)
            n_reg_len = [a-b for a,b in query_reg]
            vals = sorted(list(zip(nscores,n_reg_len,query_reg)))
            for nscore,nrl,(qs,qe) in vals:
                if marker[qs:qe].sum() == 0:
                    marker[qs:qe] = True
                    results.append((float(marker.sum())/len(marker),
                                    float(qe-qs)/len(marker),
                                    -nscore))
            header = 0
        else:
            results.append((0,0,0))
        results = ";".join(f'{marker_cov},{mask_cov},0,1,root,root,{rel_score}' for marker_cov,mask_cov,rel_score in results)
        print(f'{read_id}\t{readid}\troot\t{cur_header}\troot\t{results}')
