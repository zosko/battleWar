//
//  Model_Field.h
//  BattleWar
//
//  Created by Bosko Petreski on 6/13/18.
//  Copyright © 2018 Bosko Petreski. All rights reserved.
//

#import <Foundation/Foundation.h>

@import Cocoa;

@interface Model_Field : NSObject

@property (nonatomic,assign) BOOL isClicked;
@property (nonatomic,assign) BOOL hasShip;
@property (nonatomic,assign) NSInteger xPos;
@property (nonatomic,assign) NSInteger yPos;
@property (nonatomic,strong) NSButton *buttonField;

-(Model_Field *)initField:(NSInteger)x y:(NSInteger)y;

@end
