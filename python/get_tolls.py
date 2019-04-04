import sys
import psycopg2
import numpy as np
import pickle



#==============================================================================
# Main function
#==============================================================================
def main(argv):
    tbl = 'I10E'
    gates = [" WHERE entry_gate='ET01' AND exit_gate='ET01' ",
             " WHERE (entry_gate='ET02' OR entry_gate='ET03') AND (exit_gate='ET02' OR exit_gate='ET03') ",
             " WHERE entry_gate='ET04' AND exit_gate='ET04' ",
             " WHERE entry_gate='ET01' AND (exit_gate='ET02' OR exit_gate='ET03') ",
             " WHERE entry_gate='ET01' AND exit_gate='ET04' ",
             " WHERE (entry_gate='ET02' OR entry_gate='ET03') AND exit_gate='ET04' "]
    fname = 'py_data/i10e_tolls.pickle'
    
    
    tolls = -1 * np.ones((6, 105120))
  
    
    conn = psycopg2.connect("dbname=la_hot user=postgres")
    cur = conn.cursor()
    
    
    for i in range(0, 6):

        stmt = "SELECT ((EXTRACT(DOY FROM entry_ts)-1)*288 + EXTRACT(HOUR FROM entry_ts)*12 + (EXTRACT(MINUTE FROM entry_ts)::int / 5)), MAX(toll) FROM "
        stmt += tbl
        stmt += gates[i] 
        stmt += " AND EXTRACT(ISODOW FROM entry_ts)<6 AND EXTRACT(ISODOW FROM entry_ts)>1"
        stmt += " AND toll<18 AND TO_CHAR(entry_ts, 'HH24:MI:SS')>'16:00:00' AND TO_CHAR(entry_ts, 'HH24:MI:SS')<'18:00:00' AND NOT trx_type='VIOL'"
        stmt += " GROUP BY ((EXTRACT(DOY FROM entry_ts)-1)*288), (EXTRACT(HOUR FROM entry_ts)*12), (EXTRACT(MINUTE FROM entry_ts)::int / 5)"
        stmt += " ORDER BY ((EXTRACT(DOY FROM entry_ts)-1)*288), (EXTRACT(HOUR FROM entry_ts)*12), (EXTRACT(MINUTE FROM entry_ts)::int / 5);"
    
    
        cur.execute(stmt)  
        result = cur.fetchall()
        
        for record in result:         
            tolls[i][record[0]] = float(record[1])


    conn.commit()
    cur.close()
    conn.close()

    print(tolls)

    with open(fname, 'wb') as f:
        pickle.dump(tolls, f)
        
    f.close

    
    
    
    


if __name__ == "__main__":
    main(sys.argv)