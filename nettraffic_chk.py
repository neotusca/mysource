#!/usr/bin/python

import sys, getopt

NIC_DEV_STATUS_FILE='/proc/net/dev'



def args_chk(argv,devices):
    if len(argv) == 2:
        for device in devices:
            if argv[1] == device:
                print '...process..'
            else:
                print_help(devices)
    else:
        print_help(devices)
    return 0


def print_help(devices):
        print ""
        print "    Usage : ",sys.argv[0],"[net_device] [options] [time_interval default:2]"
        print ""
        print "    [net_device]"
        print_list(devices)
        print "    [options]"
        print "    -t : check transmit traffic (default)"
        print "    -r : check receive traffic"


def print_list(list):
    for element in list:
        print element
    return 0



def dev_fileread(device_file,mode):
    if mode != 1 and mode != 2:
        print "mode not setting in dev_fileread"
        sys.exit(2)    

    f = open(device_file,'r')
    content = f.read()
    f.close()
    #print('--------1--------')
    #print(content,type(content))
    tmp_list1 = content.split("\n")
    tmp_list1.remove('')
    #print('--------2--------')
    #print(tmp_list1,type(tmp_list1))

    tmp_list=[]
    cnt=0
    if mode == 1:    # get device-name 
        for tmp_record1 in tmp_list1:
            if cnt < 2:             # skip garbage-data
                #print(cnt)
                cnt=cnt+1
            else:
                #print tmp_record1, type(tmp_record1),'1-1'   
                tmp_record2 = tmp_record1.split(" ")     
                #print tmp_record2, type(tmp_record2),'1-2'
                tmp_record3 = remove_blank(tmp_record2)
                #print tmp_record3, type(tmp_record3),'1-3'
                if tmp_record3[0] != 'lo:' and tmp_record3[0][-1] == ':':
                    #print tmp_record3[0],'1-4'          
                    #print tmp_record3[0][:-1],'1-5'          
                    tmp_list.append(tmp_record3[0][:-1])
    elif mode == 2:   # to process network-data
        print 'mode 2'
        ######################################
        #print tmp_record1, type(tmp_record1),'1-1'
        #tmp_record2 = tmp_record1.split(" ")
        #print tmp_record2, type(tmp_record2),'1-2'
        #tmp_record3 = remove_blank(tmp_record2)
        #print tmp_record3, type(tmp_record3),'1-3'
        #if tmp_record3[0] != 'lo:' and tmp_record3[0][-1] == ':':
        #    print tmp_record3[0],'1-4'
        #    tmp_list.append(tmp_record3[0])
        ######################################
    return tmp_list

def remove_blank(list):
    LINE=[]
    for cc in list:
        if cc != '':
            #print cc
            LINE.append(cc)
    #print LINE
    return LINE
    
def process(source_list):
    #print source_list
    #print "============================================"
    cnt=0
    tmp_list=[]
    lists=[]

    for LINE in source_list:
        tmp_list = LINE.split(" ")
        #print '==',tmp_list,'=='
        tmp_list2 = remove_blank(tmp_list)
        #print '**',tmp_list2,'**'
        #print '||',tmp_list2[0],'||'

        if tmp_list2[0] != 'lo:' and tmp_list2[0][-1] == ':':
            #print tmp_list2[0]
            #print tmp_list2[0][-1]
            #print tmp_list2[0][:-1]
            tmp_list = [tmp_list2[0][:-1],tmp_list2[1],tmp_list2[2],tmp_list2[9],tmp_list2[10]]

            lists.append([])
            lists[cnt] = tmp_list
            
            print tmp_list
            print lists[cnt]
            cnt=cnt+1

    print '---------------------------------------'
    print lists
    print '---------------------------------------'

    return lists



if __name__ == "__main__":

    dev_list=dev_fileread(NIC_DEV_STATUS_FILE,1)
    #print dev_list, type(dev_list)
    args_chk(sys.argv, dev_list)
    #TMP_list1 = dev_fileread(NIC_DEV_STATUS_FILE,2)
    #TMP_list2 = process(TMP_list1)
                
    
    




###########################################################################
#  /proc/net/dev
#
#Inter-|   Receive                                                |  Transmit
#
# face |bytes    packets errs drop fifo frame compressed multicast|bytes    packets errs drop fifo colls carrier compressed
#
#enp2s0:       0       0    0    0    0     0          0         0        0       0    0    0    0     0       0          0
#
#    lo:       0       0    0    0    0     0          0         0        0       0    0    0    0     0       0          0
#
#veth307d46b:    1590      19    0    0    0     0          0         0     1782      15    0    0    0     0       0          0
#
#  eno1: 385762161 1707900    0 60185    0     0          0      5931 10942043  111702    0    0    0     0       0          0
#
#docker0:    4540      67    0    0    0     0          0         0     1782      15    0    0    0     0       0          0
