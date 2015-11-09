//
//  ORS-bridging-header.h
//  MotionControl
//
//  Created by h on 21/07/2015.
//  Copyright © 2015 slartibartfist. All rights reserved.
//

#ifndef ORS_bridging_header_h
#define ORS_bridging_header_h

#import "ORSSerialPort.h"
#import "ORSSerialPortManager.h"

int rawhid_open(int max, int vid, int pid, int usage_page, int usage);
int rawhid_recv(int num, void *buf, int len, int timeout);
int rawhid_send(int num, void *buf, int len, int timeout);
void rawhid_close(int num);



#endif /* ORS_bridging_header_h */
