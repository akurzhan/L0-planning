"""
freq2xlsx - create config spreadsheet from the FREQ config.
"""


import sys
import csv
import numpy as np




class Config:
    def __init__(self, freq_name):
        '''
        Extract freeway config data
        '''
        
        self.begin_pm = 428.5
        self.dir = -1
        self.link_length_range = [0.12, 0.24] # miles
        self.freq_freeway = []
        
        hr ="********************************************************************************************************************************"
        hr ="**************************"
        
        or_count = 0
        fr_count = 0
        
        or_indices = []
        fr_indices = []
        idx = -1
        
        slice_count = 1
        self.or_flows = None
        self.fr_flows = None
        
        f = open(freq_name, 'rb')
        
        buf = f.readline()
        while buf:
            if "FREEWAY AND ARTERIAL DESIGN FEATURES" in buf:
                cnt = 0
                while buf and cnt < 3:
                    buf = f.readline()
                    if hr in buf:
                        cnt += 1
                
                buf = f.readline()
                while hr not in buf:
                    tokens = buf.split()
                    if len(tokens) > 2:
                        idx += 1
                        section = dict()
                        section["lanes"] = float(tokens[2])
                        section["capacity"] = float(tokens[3]) / section["lanes"]
                        section["length"] = float(tokens[4]) / 5280.0 # miles
                        section["v"] = float(tokens[5])
                        section["or_lanes"] = 0
                        section["fr_lanes"] = 0
                        desc_idx = 16
                        if tokens[6] == "OD":
                            section["or_lanes"] = 1
                            section["fr_lanes"] = 1
                        elif tokens[6] == "O":
                            section["or_lanes"] = 1
                        elif tokens[6] == "D":
                            section["fr_lanes"] = 1
                        else:
                            desc_idx = 15
                        section["description"] = " ".join(tokens[desc_idx:-1])
                        
                        if section["or_lanes"] > 0:
                            or_count += 1
                            or_indices.append(idx)
                        if section["fr_lanes"] > 0:
                            fr_count += 1
                            fr_indices.append(idx)
                            
                        self.freq_freeway.append(section)
                        
                    buf = f.readline()
                    
            if "ON-RAMP CAPACITY LIMITS" in buf:
                cnt = int(np.ceil(float(or_count) / 20.0))
                f.readline()
                for i in range(cnt):
                    f.readline()
                buf = ""
                for i in range(cnt):
                    buf += f.readline() + " "
                tokens = buf.split()
                min_cap = 10000
                or_cap = []
                for i in range(len(tokens)):
                    val = float(tokens[i])
                    min_cap = np.min([min_cap, val])
                    or_cap.append(val)
                for i in range(1, or_count):
                    self.freq_freeway[or_indices[i]]["or_lanes"] = int(np.ceil(or_cap[i] / min_cap))
                    
            if "OFF-RAMP CAPACITY LIMITS" in buf:
                cnt = int(np.ceil(float(fr_count) / 20.0))
                f.readline()
                for i in range(cnt):
                    f.readline()
                buf = ""
                for i in range(cnt):
                    buf += f.readline() + " "
                tokens = buf.split()
                min_cap = 10000
                fr_cap = []
                for i in range(len(tokens)):
                    val = float(tokens[i])
                    min_cap = np.min([min_cap, val])
                    fr_cap.append(val)
                for i in range(1, fr_count):
                    self.freq_freeway[fr_indices[i]]["fr_lanes"] = int(np.ceil(fr_cap[i] / min_cap))
            
            or_lines = int(np.ceil(float(or_count-1) / 20.0))
            fr_lines = int(np.ceil(float(fr_count-1) / 20.0))
            OR_HEAD = "ORIGINAL INPUT COUNTS"
            FR_HEAD = "ORIGINAL OUTPUT COUNTS"
            
            if "TIME SLICE  {} OF".format(slice_count) in buf:
                while OR_HEAD not in buf:
                    buf = f.readline()    
                buf = ""
                for i in range(or_lines):
                    buf += f.readline() + " "
                if self.or_flows == None:
                    self.or_flows = np.zeros((or_count-1, 4))
                tokens = buf.split()
                for i in range(len(tokens)):
                    self.or_flows[i][slice_count-1] = float(tokens[i])

                while FR_HEAD not in buf:
                    buf = f.readline()    
                buf = ""
                for i in range(fr_lines):
                    buf += f.readline() + " "
                if self.fr_flows == None:
                    self.fr_flows = np.zeros((fr_count-1, 4))
                tokens = buf.split()
                for i in range(len(tokens)):
                    self.fr_flows[i][slice_count-1] = float(tokens[i])
                    
                slice_count += 1
                
            
            buf = f.readline()
        f.close()
        
        self.freq_freeway[0]["or_lanes"] = 0
        self.freq_freeway[-1]["fr_lanes"] = 0
        
        self.config_sheet = []
        self.or_flow_sheet = []
        self.fr_flow_sheet = []
        self.generate_links()
        
        return
        


    def generate_links(self):
        '''
        Generate BeATS links from FREQ sections.
        '''
        
        sz = len(self.freq_freeway)
        
        orc = 0
        frc = 0
        
        gid = 2
        pm = self.begin_pm
        for i in range(sz):
            sec = self.freq_freeway[i]
            
            gp_buf = ""
            for j in range(int(np.ceil(sec["lanes"]))):
                gp_buf += "|"
            
            segments = self.get_links_per_section(sec["length"])
            num_seg = len(segments)
            for j in range(num_seg):
                hov_id = 0
                hov_buf = ""
                if i > 0:
                    hov_id = 1000 + gid
                    hov_buf = "H"
                    
                or_id = 0
                or_lanes = 0
                or_buf = ""
                if sec["or_lanes"] > 0 and j == 0:
                    or_id = 2000 + gid
                    or_lanes = sec["or_lanes"]
                if i < (sz-1) and j == (num_seg-1) and self.freq_freeway[i+1]["or_lanes"] > 0:
                    or_buf = "\\"
                
                fr_id = 0
                fr_lanes = 0
                fr_buf = ""
                if i > 0 and self.freq_freeway[i-1]["fr_lanes"] > 0 and j == 0:
                    fr_id = 3000 + gid - 1
                    fr_lanes = self.freq_freeway[i-1]["fr_lanes"]
                    fr_buf = "/"
                
                comment = ""
                if or_id > 0 or fr_id > 0:
                    comment = sec["description"]
                        
                sbuf = "{},{},0,{},{},,{},0,{},1,1900,1500,65,48,{},{},0,,,0,0,{},{},{},{}".format(                     
                        gid, 
                        hov_id,
                        pm,
                        segments[j], 
                        or_buf+fr_buf+gp_buf+hov_buf,
                        int(np.ceil(sec["lanes"])),
                        or_id,
                        or_lanes,
                        fr_id,
                        fr_lanes,
                        comment,
                        gid+1)
                print(i, sbuf)
                self.config_sheet.append(sbuf)
                
                vcounts = None
                if (gid == 2 or or_id > 0) and orc < len(self.or_flows):
                    vcounts = self.or_flows[orc]
                    orc += 1
                    
                or_buf = self.get_5min_flows(vcounts)
                self.or_flow_sheet.append(or_buf)
                    
                vcounts = None
                if fr_id > 0 and frc < len(self.fr_flows):
                    vcounts = self.fr_flows[frc]
                    frc += 1
                    
                fr_buf = self.get_5min_flows(vcounts)
                self.fr_flow_sheet.append(fr_buf)
                                    
                
                gid += 1
                pm -= segments[j]
                
        return
        

      
    def get_links_per_section(self, section_length):
        '''
        Figure out how many links will fit the section.
        '''
        
        num_links = np.floor(section_length / self.link_length_range[0])
        
        num_links = np.floor(num_links)
        res = section_length - num_links*self.link_length_range[0]
        
        if num_links < 1:
            return [self.link_length_range[0]]
        
        dx = self.link_length_range[0] + (res / num_links)
        
        return [dx] * int(num_links)
        
            

    def get_5min_flows(self, vcounts, slots=12):
        '''
        Generate 288-value profile.
        '''

        buf = ""
        
        if vcounts == None:
            for i in range(288):
                buf += "0"
                if i < 287:
                    buf += ","
            return buf
            
        sz = len(vcounts)
        slot = 0
        for i in range(sz):
            for j in range(slots):
                buf += "{},".format(int(vcounts[i]))
                slot += 1
        
        for i in range(slot, 288):
            buf += "0"
            if i < 287:
                buf += ","
        
        return buf







#==============================================================================
# Main function.
#==============================================================================
def main(argv):
    print(__doc__)
    
    try:
        freq_fname = argv[2]
    except:
        freq_name = "I101SB_Data.xlsx"
        
    try:
        freq_fname = argv[1]
    except:
        freq_name = "freq_output.txt"
        
        
        c = Config(freq_name)
    
    


if __name__ == "__main__":
    main(sys.argv)



