import sys
import pickle
import numpy as np
import matplotlib.pyplot as plt


#==============================================================================
# Least squares
#==============================================================================
def test_lstsq():
    A = np.array([[1, 1, 1],
                 [0, 1, 1]])
    b = np.array([6, 2])
    
    x = np.linalg.lstsq(A, b)
    
    print(x[0])
    
    
    
    
#==============================================================================
# Beta convergence
#==============================================================================
def example_beta():
    frf = 20
    gp = 80
    hov = 20
    cap = 81    
    
    beta = [0]
    r = (frf*gp) / (cap * (gp+hov) - frf*hov)
    eq = [r]
    
    for i in range(0, 10):
        a = cap / (beta[-1]*hov + gp)
        a = np.min([1, a])
        print(a)
        b = (frf - a*(beta[-1]*hov)) / (a*gp)
        beta.append(b)
        eq.append(r)
    

    print(beta)
    
    plt.rc('text', usetex=True)
    plt.plot(eq, 'r')
    plt.plot(beta, 'b-.')
    plt.xlabel('Iteration')
    plt.ylabel(r'$\beta$')
    plt.show()




#==============================================================================
# Double beta convergence
#==============================================================================
def example_double_beta():
    frf1 = 20
    frf2 = 10
    gp = 80
    hov = 20
    cap = 80    
    
    beta1 = [0]
    beta2 = [0]
    r1 = (frf1*gp) / (cap * (gp+hov) - frf1*hov)
    gp2 = (1-r1)*gp
    hov2 = (1-r1)*hov
    r2 = (frf2*gp2) / (cap * (gp2+hov2) - frf2*hov2)
    eq1 = [r1]
    eq2 = [r2]
    
    for i in range(0, 10):
        a = cap / (beta2[-1]*(1-beta1[-1])*hov + beta1[-1]*hov + gp)
        a = np.min([1, a])
        b1 = (frf1 - a*(beta1[-1]*hov)) / (a*gp)
        b2 = (frf2 - a*(beta2[-1]*(1-beta1[-1])*hov)) / (a*(1-beta1[-1])*gp)
        beta1.append(b1)
        beta2.append(b2)
        eq1.append(r1)
        eq2.append(r2)
    
    print(beta2)
    
    plt.rc('text', usetex=True)
    plt.plot(eq1, 'r')
    plt.plot(eq2, 'm')
    plt.plot(beta1, 'b-.')
    plt.plot(beta2, 'k-.')
    plt.xlabel('Iteration')
    plt.ylabel(r'$\beta$')
    plt.show()





#==============================================================================
# Beta hat convergence
#==============================================================================
def example_beta_hat():
    frf = 20
    gp = 80
    hov = 20
    betahat = [0]
    beta = [0.25]
    eq1 = [0.236]
    eq2 = [0.191]
    
    for i in range(0, 10):
        bhat = frf / (gp + betahat[-1]*hov)
        b = (frf - betahat[-1]*hov) / gp
        betahat.append(bhat)
        beta.append(b)
        eq1.append(0.236)
        eq2.append(0.191)
        
    print(beta)
    print(betahat)
        
    plt.rc('text', usetex=True)
    plt.plot(eq1, 'm')
    plt.plot(eq2, 'r')
    plt.plot(beta, 'b-.')
    plt.plot(betahat, 'k-.')
    plt.xlabel('Iteration')
    plt.ylabel(r'$\beta$, $\hat{\beta}$')
    plt.show()



def print_csv(profiles):
    
    buf = ""
    for key in profiles.keys():
        buf += key + ","
        
    print(buf)
    
    for i in range(0, 288):
        buf = ""
        for key in profiles.keys():
            buf += str(profiles[key][i]) + ","
        
        print(buf)
        
        

def test_profiles():
    fname = 'py_data/i10e_5min_toll_global_profiles.pickle'
    
    with open(fname, 'rb') as f:
        g_profiles = pickle.load(f)
    f.close
    
    print_csv(g_profiles)



#==============================================================================
# Main function
#==============================================================================
def main(argv):
    example_double_beta()
    
                 






if __name__ == "__main__":
    main(sys.argv)