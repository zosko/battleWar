//
//  ViewController.h
//  BattleWarIOS
//
//  Created by Bosko Petreski on 6/19/18.
//  Copyright © 2018 Bosko Petreski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCDAsyncUdpSocket.h"

@interface ViewController : UIViewController <GCDAsyncUdpSocketDelegate>{
    GCDAsyncUdpSocket *udpSocket;
    IBOutlet UILabel *lblTurn;
    NSString *strMineIpAddress;
    NSString *strOpponentIpAddress;
}


@end

