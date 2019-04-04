import sys
import psycopg2
import numpy as np
import pickle


#==============================================================================
# Main function
#==============================================================================
def main(argv):
    tbl = 'I10E'
    #occ = 'HOV-2'
    #occ = 'HOV-3'
    occ = 'SOV'
    #fname = 'py_data/i10e_hov2_hourly_counts.pickle'
    #fname = 'py_data/i10e_hov3_hourly_counts.pickle'
    #fname = 'py_data/i10e_sov_hourly_counts.pickle'
    fname = 'py_data/i10e_total_hourly_counts.pickle'
    week = ['0', '1', '2', '3', '4', '5', '6']
    
    
    conn = psycopg2.connect("dbname=la_hot user=postgres")
    cur = conn.cursor()
    
    hourly_counts = []
    hourly_tolls = []
    
    for dow in week:
        stmt = "SELECT DATE(entry_ts), extract(HOUR FROM entry_ts), count(entry_ts), sum(toll) as total_count FROM "
        stmt += tbl
        stmt += " WHERE EXTRACT(DOW FROM entry_ts) = " + dow
        #stmt += " AND occupancy = '" + occ + "'"
        stmt += " GROUP BY DATE(entry_ts), extract(HOUR FROM entry_ts)"
        stmt += " ORDER BY DATE(entry_ts), extract(HOUR FROM entry_ts);"
    
        cur.execute(stmt)
        
        result = cur.fetchall()
        
        dow_counts = np.array([])
        dow_tolls = np.array([])

        counts = np.array([])
        tolls = np.array([])
        
        hour = 0
        
        for record in result:
            
            if hour > record[1]:
                for i in range(hour+1, 24):
                    counts = np.hstack((counts, 0))
                    tolls = np.hstack((tolls, float(0.0)))
                    
                if len(dow_counts) == 0:
                    dow_counts = counts;
                    dow_tolls = tolls;
                else:
                    dow_counts = np.vstack((dow_counts, counts))
                    dow_tolls = np.vstack((dow_tolls, tolls))
                    
                counts = np.array([])
                tolls = np.array([])
                
                for i in range(0, int(record[1])):
                    counts = np.hstack((counts, 0))
                    tolls = np.hstack((tolls, float(0.0)))
                
            else:
                for i in range(hour+1, int(record[1])):
                    counts = np.hstack((counts, 0))
                    tolls = np.hstack((tolls, float(0.0)))
            
            counts = np.hstack((counts, record[2]))
            tolls = np.hstack((tolls, float(record[3])))
            hour = int(record[1])
            
             
        hourly_counts.append(dow_counts)
        hourly_tolls.append(dow_tolls)
            

    conn.commit()
    cur.close()
    conn.close()


    with open(fname, 'wb') as f:
        pickle.dump([hourly_counts, hourly_tolls], f)
        
    f.close






if __name__ == "__main__":
    main(sys.argv)