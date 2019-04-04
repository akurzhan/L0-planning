import sys
import psycopg2
import pickle


#==============================================================================
# Main function
#==============================================================================
def main(argv):
    tbl = 'I10E'
    #occ = 'HOV-2'
    #occ = 'HOV-3'
    occ = 'SOV'
    #fname = 'py_data/i10e_hov2_dow_counts.pickle'
    #fname = 'py_data/i10e_hov3_dow_counts.pickle'
    #fname = 'py_data/i10e_sov_dow_counts.pickle'
    fname = 'py_data/i10e_total_dow_counts.pickle'
    week = ['0', '1', '2', '3', '4', '5', '6']
    
    
    conn = psycopg2.connect("dbname=la_hot user=postgres")
    cur = conn.cursor()
    
    dow_counts = []
    dow_tolls = []
    
    for dow in week:
        stmt = "SELECT DATE(entry_ts), count(entry_ts), sum(toll) as total_count from "
        stmt += tbl
        stmt += " WHERE EXTRACT(DOW FROM entry_ts) = " + dow
        #stmt += " AND occupancy = '" + occ + "'"
        stmt += " GROUP BY DATE(entry_ts) "
        stmt += " ORDER BY DATE(entry_ts);"
    
        cur.execute(stmt)
        
        result = cur.fetchall()
        
        counts = []
        tolls = []

        for record in result:
            counts.append(record[1])
            tolls.append(float(record[2]))
             
        dow_counts.append(counts)
        dow_tolls.append(tolls)
            

    conn.commit()
    cur.close()
    conn.close()


    with open(fname, 'wb') as f:
        pickle.dump([dow_counts, dow_tolls], f)
        
    f.close






if __name__ == "__main__":
    main(sys.argv)