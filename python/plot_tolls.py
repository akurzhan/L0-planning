import sys
import pickle
import numpy as np
import matplotlib.pyplot as plt


#==============================================================================
# Main function
#==============================================================================
def main(argv):
    data_file = 'py_data/i10e_tolls.pickle'
    t1 = 3
    t2 = 5
    
    tolls1 = np.array([])
    tolls2 = np.array([])

    with open(data_file, 'rb') as f:
        tolls = pickle.load(f)
    f.close
    
    (m, n) = tolls.shape
    
    for i in range(0, n):
        if (tolls[t1][i] > 0) and (tolls[t2][i] > 0):
            tolls1 = np.hstack((tolls1, tolls[t1][i]))
            tolls2 = np.hstack((tolls2, tolls[t2][i]))

    
    plt.scatter(tolls1, tolls2, s=np.pi*10, alpha=0.25)
    plt.show()
    
    cc = np.corrcoef(tolls1, tolls2)
    print(cc)



if __name__ == "__main__":
    main(sys.argv)