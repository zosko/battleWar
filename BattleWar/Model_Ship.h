//
//  Model_Ship.h
//  BattleWar
//
//  Created by Bosko Petreski on 6/13/18.
//  Copyright © 2018 Bosko Petreski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Model_Ship : NSObject

@property (nonatomic,assign) NSInteger boatSize;
@property (nonatomic,strong) NSArray *fields;
@property (nonatomic,assign) BOOL isHorisontal;

-(Model_Ship *)initBoatSize:(NSInteger)boatSize field:(id)field horisontal:(BOOL)isHorisontal grid:(NSArray *)grid;

-(BOOL)isDesroyed;

@end
