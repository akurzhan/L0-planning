import sys


#==============================================================================
# Fix time stamp format: DD-Mon-YY hh:mm:ss.xx AM/PM
#==============================================================================
def fix_ts(ts):
    [p1, p2, p3, p4] = ts.split('.')
    ts = p1 + ':' + p2 + ':' + p3 + '.' + p4
    return ts



#==============================================================================
# Main function
#==============================================================================
def main(argv):
    fwy = 'I-110'
        
        
    for line in sys.stdin:

        line = line.rstrip()   # remove trailing characters
        [trp, acct, a_type, b_ts, e_ts, trx, b_gate, e_gate, occ, zipcode, toll, trx_type] =\
            line.split('\t')   # split string into components
            
        if acct == 'ACCT_NO':
            continue
        
                       
        print ('{0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11}'.format(fwy, acct, a_type, fix_ts(b_ts), fix_ts(e_ts), trx, b_gate, e_gate, occ, zipcode, toll, trx_type))



if __name__ == "__main__":
    main(sys.argv)
