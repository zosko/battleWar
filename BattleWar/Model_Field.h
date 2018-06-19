//
//  Model_Field.h
//  BattleWar
//
//  Created by Bosko Petreski on 6/13/18.
//  Copyright © 2018 Bosko Petreski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Model_Ship.h"

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
@import Cocoa;
#endif

@interface Model_Field : NSObject

@property (nonatomic,assign) BOOL isClicked;
@property (nonatomic,assign) BOOL hasShip;
@property (nonatomic,assign) NSInteger xPos;
@property (nonatomic,assign) NSInteger yPos;
@property (nonatomic,strong) Model_Ship *ship;

#if TARGET_OS_IPHONE
@property (nonatomic,strong) UIButton *buttonField;
#else
@property (nonatomic,strong) NSButton *buttonField;
#endif

-(Model_Field *)initField:(NSInteger)x y:(NSInteger)y;

@end
