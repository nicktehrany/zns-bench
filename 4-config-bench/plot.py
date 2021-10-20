#!/usr/bin/pyton3
import matplotlib.pyplot as plt
import numpy as np
import statistics
import pandas as pd
import os
import glob
import matplotlib.ticker as ticker
from matplotlib.ticker import FormatStrFormatter

benchmarks = ["fillseq", "fillrandom", "overwrite", "updaterandom", "readseq", "readrandom"]
configs = ["config-1", "config-2", "config-3", "config-4"]
types = ["microsec/op", "ops/sec", "MB/sec"]

# CHANGE DATADIR HERE!
DATADIR="data_node3_nullblk" 

def plot(data, type):
    write = benchmarks[:4]
    read = benchmarks[4:]
    plot_benchmarks(data, type, write, "Write")
    plot_benchmarks(data, type, read, "Read")

def plot_perf(data, type, benchmark):
    vals = []
    stdevs = []
    for config in configs:
        vals.append(data[config][benchmark]['val'])
        stdevs.append(data[config][benchmark]['stdev'])

    y_pos = np.arange(len(vals))
    plt.bar(y_pos, vals, color=["blue", "orange", "green", "red"], yerr=stdevs, capsize=5, zorder=3)
    plt.xticks(y_pos, configs)
    plt.xlabel("Configuration")
    plt.ylabel(type)
    plt.title(f"{type} for {benchmark}")
    plt.grid(which='major', linestyle='dashed', linewidth='1', zorder=0)
    name = type.replace("/", "-")
    # pdf for paper and png for google docs
    plt.savefig(f"{DATADIR}/perf/plots/pdf/{benchmark}-{name}.pdf", bbox_inches="tight")
    plt.savefig(f"{DATADIR}/perf/plots/png/{benchmark}-{name}.png", bbox_inches="tight")
    plt.clf()


def plot_benchmarks(data, type, benchs, t):
    config_1 = []
    config_2 = []
    config_3 = []
    config_4 = []
    config_1_stdev = []
    config_2_stdev = []
    config_3_stdev = []
    config_4_stdev = []

    for benchmark in benchs:
        config_1.append(data['config-1'][benchmark]['val'])
        config_2.append(data['config-2'][benchmark]['val'])
        config_3.append(data['config-3'][benchmark]['val'])
        config_4.append(data['config-4'][benchmark]['val'])
        config_1_stdev.append(data['config-1'][benchmark]['stdev'])
        config_2_stdev.append(data['config-2'][benchmark]['stdev'])
        config_3_stdev.append(data['config-3'][benchmark]['stdev'])
        config_4_stdev.append(data['config-4'][benchmark]['stdev'])

    x = np.arange(len(benchs)) 
    width = 0.2
    fig, ax = plt.subplots()
    rects1 = ax.bar(x - 3*(width/2), config_1, width, yerr=config_1_stdev, capsize=5, label='Config-1')
    rects2 = ax.bar(x - width/2, config_2, width, yerr=config_2_stdev, capsize=5, label='Config-2')
    rects3 = ax.bar(x + width/2, config_3, width, yerr=config_3_stdev, capsize=5, label='Config-3')
    rects4 = ax.bar(x + 3*(width/2), config_4, width, yerr=config_4_stdev, capsize=5, label='Config-4')

    ax.set_ylabel(type)
    ax.set_xlabel("Benchmark")
    ax.set_title(f"{type} for {t} Operations")
    ax.set_xticks(x)
    ax.set_xticklabels(benchs)
    ax.legend(loc='best')
    
    # This shows the value at the top of the bar
    #ax.bar_label(rects1, fontsize=8, padding=3, fmt="%.1f")
    #ax.bar_label(rects2, fontsize=8, padding=3, fmt="%.1f")
    #ax.bar_label(rects3, fontsize=8, padding=3, fmt="%.1f")
    #ax.bar_label(rects4, fontsize=8, padding=3, fmt="%.1f")

    fig.tight_layout()
    ax.get_yaxis().set_major_formatter(ticker.FuncFormatter(lambda x, p: format(int(x), ',')))
    ax.set_axisbelow(True)
    ax.grid(which='major', linestyle='dashed', linewidth='1')
    name = type.replace("/", "-")
    # pdf for paper and png for google docs
    plt.savefig(f"{DATADIR}/db_bench/plots/pdf/{name}-{t}.pdf", bbox_inches="tight")
    plt.savefig(f"{DATADIR}/db_bench/plots/png/{name}-{t}.png", bbox_inches="tight")
    plt.clf()
    

if __name__ == "__main__":
    data = dict(dict(dict(dict())))

    # Init the nested dict
    data['db_bench'] = dict()
    for type in types:
        data['db_bench'][type] = dict()
        for config in configs:
            data['db_bench'][type][config] = dict()
            for benchmark in benchmarks:
                data['db_bench'][type][config][benchmark] = dict()
                data['db_bench'][type][config][benchmark]['val'] = 0
                data['db_bench'][type][config][benchmark]['stdev'] = 0

    for benchmark in benchmarks:
        for config in configs:
            # If data is in different dir change the argument below
            files = glob.glob(f"{DATADIR}/db_bench/{benchmark}-{config}.dat")
            for file in files:
                df = pd.read_csv(file,
                    sep="\s+", 
                    skiprows=1, 
                    names=types)
                for type in types:
                    data['db_bench'][type][config][benchmark]['val'] = statistics.mean(df[type])
                    data['db_bench'][type][config][benchmark]['stdev'] = statistics.stdev(df[type])

    os.makedirs(f"{DATADIR}/db_bench/plots/pdf", exist_ok=True)
    os.makedirs(f"{DATADIR}/db_bench/plots/png", exist_ok=True)

    for type in types:
        plot(data['db_bench'][type], type)

    
    #######################################
    ########### PERF PLOTTING #############
    #######################################

    types = ["secs", "user-secs", "sys-secs", "cycles", "instructions", "inst/cycle", "context-switches", "page-faults"]
    data['perf'] = dict()
    for type in types:
        data['perf'][type] = dict()
        for config in configs:
            data['perf'][type][config] = dict()
            for benchmark in benchmarks:
                data['perf'][type][config][benchmark] = dict()
                data['perf'][type][config][benchmark]['val'] = 0
                data['perf'][type][config][benchmark]['stdev'] = 0
    
    for benchmark in benchmarks:
        for config in configs:
            files = glob.glob(f"{DATADIR}/perf/{benchmark}-{config}.dat")
            for file in files:
                df = pd.read_csv(file,
                    sep="\s+", 
                    skiprows=1, 
                    names=types)
                df = df.replace(',','', regex=True)
                df["cycles"] = pd.to_numeric(df["cycles"])
                df["instructions"] = pd.to_numeric(df["instructions"])
                df["page-faults"] = pd.to_numeric(df["page-faults"])
                df["context-switches"] = pd.to_numeric(df["context-switches"])
                for type in types:
                    data['perf'][type][config][benchmark]['val'] = statistics.mean(df[type])
                    data['perf'][type][config][benchmark]['stdev'] = statistics.stdev(df[type])

    os.makedirs(f"{DATADIR}/perf/plots/pdf", exist_ok=True)
    os.makedirs(f"{DATADIR}/perf/plots/png", exist_ok=True)

    for benchmark in benchmarks:
        for type in types:
            plot_perf(data['perf'][type], type, benchmark)
