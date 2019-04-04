import sys
import pickle
#import numpy as np
import matplotlib.pyplot as plt


#==============================================================================
# Main function
#==============================================================================
def main(argv):
    data_files = ['py_data/i10e_hov3_dow_counts.pickle',
                  'py_data/i10e_hov2_dow_counts.pickle',
                  'py_data/i10e_sov_dow_counts.pickle',
                  'py_data/i10e_total_dow_counts.pickle']
    titles = ['HOV-3', 'HOV-2', 'SOV', 'TOTAL']
    
    labels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
    fs = 14
    
    fig, axes = plt.subplots(nrows=2, ncols=4, figsize=(6,6))
    
    for i in range(0, 4):

        with open(data_files[i], 'rb') as f:
            dow_counts, dow_tolls = pickle.load(f)
        f.close
        
        axes[0, i].boxplot(dow_counts)
        axes[0, i].set_title(titles[i], fontsize=fs)
        axes[0, i].set_xticklabels([])
        axes[0, i].set_ylim(0, 25000)
        
        axes[1, i].boxplot(dow_tolls, labels=labels)
        axes[1, i].set_ylim(0, 50000)
        xtickNames = plt.setp(axes[1, i], xticklabels=labels)
        plt.setp(xtickNames, rotation=45)
        #axes[1, i].setp(labels, rotation=45, fontsize=fs-2)
        
        if i == 0:
            axes[0, i].set_ylabel('Vehicle Counts', fontsize=fs-2)
            axes[1, i].set_ylabel('Daily Tolls Collected', fontsize=fs-2)
        else:
            axes[0, i].set_yticklabels([])
            axes[1, i].set_yticklabels([])
            
    
    
    fig.subplots_adjust(hspace=0.1)
    fig.subplots_adjust(wspace=0.05)

    plt.show()




if __name__ == "__main__":
    main(sys.argv)