import sys
import pickle
import numpy as np
import matplotlib.pyplot as plt


#==============================================================================
# Main function
#==============================================================================
def main(argv):
    data_files = ['py_data/i10e_hov3_hourly_counts.pickle',
                  'py_data/i10e_hov2_hourly_counts.pickle',
                  'py_data/i10e_sov_hourly_counts.pickle',
                  'py_data/i10e_total_hourly_counts.pickle']
    titles = ['HOV-3', 'HOV-2', 'SOV', 'TOTAL']
    
    labels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
    fs = 14
    #tt = np.arange(23)
    
    fig, axes = plt.subplots(nrows=7, ncols=4, figsize=(6,6))
    fig2, axes2 = plt.subplots(nrows=7, ncols=4, figsize=(6,6))
    
    for j in range(0, 4):

        with open(data_files[j], 'rb') as f:
            hourly_counts, hourly_tolls = pickle.load(f)
        f.close
        
        sz = len(hourly_counts)
        
        for i in range(0, sz):
            avg = np.average(hourly_counts[i], axis=0)
            axes[i, j].plot(np.transpose(hourly_counts[i]), 'c')
            axes[i, j].plot(avg, 'k', linewidth=2)
            axes[i, j].set_xlim(0, 24)
            axes[i, j].set_ylim(0, 3000)

            avg2 = np.average(hourly_tolls[i], axis=0)
            axes2[i, j].plot(np.transpose(hourly_tolls[i]), 'c')
            axes2[i, j].plot(avg2, 'k', linewidth=2)
            axes2[i, j].set_xlim(0, 24)
            axes2[i, j].set_ylim(0, 6000)
            
            if i == 0:
                axes[i, j].set_title(titles[j], fontsize=fs)
                axes2[i, j].set_title(titles[j], fontsize=fs)
            
            if i < sz - 1:
                axes[i, j].set_xticklabels([])
                axes2[i, j].set_xticklabels([])
            else:
                axes[i, j].set_xlabel('Time (Hours)')
                axes2[i, j].set_xlabel('Time (Hours)')
                            
            if j == 0:
                axes[i, j].set_ylabel(labels[i] + ' Counts', fontsize=fs-2)
                axes2[i, j].set_ylabel(labels[i] + ' Tolls', fontsize=fs-2)
            else:
                axes[i, j].set_yticklabels([])
                axes2[i, j].set_yticklabels([])
    
    
    fig.subplots_adjust(hspace=0.1)
    fig.subplots_adjust(wspace=0.01)
    fig2.subplots_adjust(hspace=0.1)
    fig2.subplots_adjust(wspace=0.01)


    plt.show()



if __name__ == "__main__":
    main(sys.argv)