import sys
import psycopg2
import numpy as np
import pickle


#==============================================================================
# Initialization
#==============================================================================
#def init_data(gates):






#==============================================================================
# Main function
#==============================================================================
def main(argv):
    tbl = 'I10E'
    gate = 'ET04'
    fname = 'py_data/i10e_et04_flows_tolls.pickle'
    
    
    raw_flows = np.zeros(105120)
    #raw_flows = np.zeros(525600)
    flows = np.array([])
    tolls = np.array([])
  
    

    conn = psycopg2.connect("dbname=la_hot user=postgres")
    cur = conn.cursor()
    
    
    stmt1 = "SELECT ((EXTRACT(DOY FROM exit_ts)-1)*288 + EXTRACT(HOUR FROM exit_ts)*12 + (EXTRACT(MINUTE FROM exit_ts)::int / 15)), COUNT(*) FROM "
    stmt1 += tbl
    stmt1 += " WHERE exit_gate='ET04'"
    stmt1 += " GROUP BY ((EXTRACT(DOY FROM exit_ts)-1)*288), (EXTRACT(HOUR FROM exit_ts)*12), (EXTRACT(MINUTE FROM exit_ts)::int / 15)"
    stmt1 += " ORDER BY ((EXTRACT(DOY FROM exit_ts)-1)*288), (EXTRACT(HOUR FROM exit_ts)*12), (EXTRACT(MINUTE FROM exit_ts)::int / 15);"

    stmt2 = "SELECT ((EXTRACT(DOY FROM exit_ts)-1)*288 + EXTRACT(HOUR FROM exit_ts)*12 + (EXTRACT(MINUTE FROM exit_ts)::int / 15)), AVG(toll) FROM "
    stmt2 += tbl
    stmt2 += " WHERE exit_gate='ET04' AND entry_gate='ET04' AND EXTRACT(ISODOW FROM entry_ts)<6 AND EXTRACT(ISODOW FROM entry_ts)>1"
    #stmt2 += " AND DATE(exit_ts)='2014-01-29'"
    stmt2 += " AND occupancy='SOV' AND toll<18 AND TO_CHAR(entry_ts, 'HH24:MI:SS')>'16:00:00' AND TO_CHAR(entry_ts, 'HH24:MI:SS')<'18:00:00' AND NOT trx_type='VIOL'"
    stmt2 += " GROUP BY ((EXTRACT(DOY FROM exit_ts)-1)*288), (EXTRACT(HOUR FROM exit_ts)*12), (EXTRACT(MINUTE FROM exit_ts)::int / 15)"
    stmt2 += " ORDER BY ((EXTRACT(DOY FROM exit_ts)-1)*288), (EXTRACT(HOUR FROM exit_ts)*12), (EXTRACT(MINUTE FROM exit_ts)::int / 15);"
    
    
    cur.execute(stmt1)  
    result = cur.fetchall()
        
    for record in result:         
        raw_flows[record[0]] = record[1]


    cur.execute(stmt2)  
    result = cur.fetchall()
        
    for record in result:
        flows = np.hstack((flows, raw_flows[record[0]]))
        tolls = np.hstack((tolls, float(record[1])))

        
          
            

    conn.commit()
    cur.close()
    conn.close()



    with open(fname, 'wb') as f:
        pickle.dump([flows, tolls], f)
        
    f.close

    
    
    
    
    
    





if __name__ == "__main__":
    main(sys.argv)