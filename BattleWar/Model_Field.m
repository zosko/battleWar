//
//  Model_Field.m
//  BattleWar
//
//  Created by Bosko Petreski on 6/13/18.
//  Copyright © 2018 Bosko Petreski. All rights reserved.
//

#import "Model_Field.h"

@implementation Model_Field

-(Model_Field *)initField:(NSInteger)x y:(NSInteger)y{
    self = [super init];
    if (self) {
        self.xPos = x;
        self.yPos = y;
    }
    return self;
}


@end
