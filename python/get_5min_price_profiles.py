import sys
import psycopg2
import numpy as np
import pickle


#==============================================================================
# Initialization
#==============================================================================
def init_data(gates):
    sz = len(gates)
    data = []    
    
    for k in range(0, 7):
        dow_data = dict()
        
        for i in range(0, sz):
            for j in range(i, sz):
                key = gates[i] + gates[j]
                dow_data[key] = np.zeros(288)
                
        data.append(dow_data)
        
    return data




#==============================================================================
# Main function
#==============================================================================
def main(argv):
    tbl = 'I10E'
    gates = ['ET01', 'ET02', 'ET03', 'ET04']
    dow = ['0', '1', '2', '3', '4', '5', '6']
    fname = 'py_data/i10e_5min_toll_profiles.pickle'
  

    profiles = init_data(gates)
    

    conn = psycopg2.connect("dbname=la_hot user=postgres")
    cur = conn.cursor()
    
    
    for i in range(0, 7):
        stmt = "SELECT entry_gate, exit_gate, (EXTRACT(HOUR FROM entry_ts)*12 + (EXTRACT(MINUTE FROM entry_ts)::int / 5)), AVG(toll) FROM "
        stmt += tbl
        stmt += " WHERE EXTRACT(DOW FROM entry_ts) = " + dow[i]
        stmt += " AND NOT trx_type = 'VIOL' AND toll > 0 AND toll < 18"
        stmt += " GROUP BY entry_gate, exit_gate, (EXTRACT(HOUR FROM entry_ts)*12 + (EXTRACT(MINUTE FROM entry_ts)::int / 5))"
        stmt += " ORDER BY entry_gate, exit_gate, (EXTRACT(HOUR FROM entry_ts)*12 + (EXTRACT(MINUTE FROM entry_ts)::int / 5));"
    
        cur.execute(stmt)
        
        result = cur.fetchall()
        
        
        for record in result:
            
           key = record[0] + record[1]
           idx = record[2]
           price = record[3]
           
           profiles[i][key][idx] = price
           
            

    conn.commit()
    cur.close()
    conn.close()


    with open(fname, 'wb') as f:
        pickle.dump(profiles, f)
        
    f.close






if __name__ == "__main__":
    main(sys.argv)