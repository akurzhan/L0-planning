'''
Generate prelim config for BeATS planning.
'''

import sys
import numpy as np
import datetime as dt
import csv
import os.path
import pickle



# ==============================================================================
# Main function - for standalone execution.
# ==============================================================================

def main(argv):
    print(__doc__)

    in_csv = "i10w.csv"
    out_csv = "i10w_prelim.csv"
    pm = 28.78  # starting postmile
    c = 1.0 / 5280.0  # conversion from feet to miles
    dir = -1  # 1 for NB/EB; -1 for SB/WB
    lid = 1

    with open(in_csv, 'r') as f:
        reader = csv.reader(f)
        data = [r for r in reader]
        f.close()

    f = open(out_csv, 'w')
    sz = len(data)
    for i in range(sz):
        hid = 1000 + lid
        name = data[i][0]
        type = data[i][4]
        type_next = ""
        if i < sz - 1:
            type_next = data[i+1][4]
        lane_buf, h_lane_buf,or_buf, fr_buf = "", "", "", ""
        lanes = int(data[i][1])
        h_lanes = int(data[i][2])
        for l in range(lanes):
            lane_buf += "|"
        for l in range(h_lanes):
            h_lane_buf += "H"

        sub_len = data[i][3].split(';')
        sz2 = len(sub_len)
        for j in range(sz2):
            length = c * float(sub_len[j])
            if j == sz2-1 and type_next == "OR":
                or_buf = "\\"
            if j == 0 and type == "FR":
                fr_buf = "/"
            else:
                fr_buf = ""
            desc = "{}{}{}{}".format(or_buf, fr_buf, lane_buf, h_lane_buf)
            buf = "{},{},{},{},0,0,{},{}\n".format(lid, hid, round(pm, 2), round(length, 4), desc, name)
            f.write(buf)

            name = ""
            lid += 1
            pm += dir * length


    f.close()










if __name__ == "__main__":
    main(sys.argv)