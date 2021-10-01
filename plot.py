#!/usr/bin/pyton3
import matplotlib.pyplot as plt
import numpy as np
import statistics
import pandas as pd
import os
import glob
import matplotlib.ticker as ticker

benchmarks = ["Fillseq", "Fillrand", "Overwrite", "Updaterandom", "Readseq", "Readrand"]
configs = ["config-1", "config-2", "config-3", "config-4"]
types = ["microsec/op", "ops/sec", "MB/sec"]


def plot(data, type):
    write = benchmarks[:4]
    read = benchmarks[4:]
    plot_benchmarks(data, type, write, "Write")
    plot_benchmarks(data, type, read, "Read")

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
    plt.savefig(f"plots/{name}-{t}.png", bbox_inches="tight")
    plt.clf()
    

if __name__ == "__main__":
    results = dict(dict(dict()))
    
    # Init the nested dict
    for type in types:
        results[type] = dict()
        for config in configs:
            results[type][config] = dict()
            for benchmark in benchmarks:
                results[type][config][benchmark] = dict()
                results[type][config][benchmark]['val'] = 0
                results[type][config][benchmark]['stdev'] = 0

    for benchmark in benchmarks:
        for config in configs:
            files = glob.glob(f"results/{benchmark}-{config}.dat")
            for file in files:
                df = pd.read_csv(file,
                    sep="\s+", 
                    skiprows=1, 
                    names=types)
                for type in types:
                    results[type][config][benchmark]['val'] = statistics.mean(df[type])
                    results[type][config][benchmark]['stdev'] = statistics.stdev(df[type])

    os.makedirs("plots", exist_ok=True)

    for type in types:
        plot(results[type], type)
