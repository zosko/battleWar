//
//  ViewController.h
//  BattleWar
//
//  Created by Bosko Petreski on 6/13/18.
//  Copyright © 2018 Bosko Petreski. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GCDAsyncUdpSocket.h"

@interface ViewController : NSViewController <GCDAsyncUdpSocketDelegate>{
    GCDAsyncUdpSocket *udpSocket;
    IBOutlet NSTextField *lblTurn;
    NSString *strMineIpAddress;
    NSString *strOpponentIpAddress;
}


@end

