import sys
import pickle
import numpy as np
import matplotlib.pyplot as plt


#==============================================================================
# Main function
#==============================================================================
def main(argv):
    data_file = 'py_data/i10e_et04_flows_tolls.pickle'

    with open(data_file, 'rb') as f:
        flows, tolls = pickle.load(f)
    f.close
    
    plt.scatter(tolls, flows, s=np.pi*10, alpha=0.25)
       

    plt.show()



if __name__ == "__main__":
    main(sys.argv)