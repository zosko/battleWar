//
//  Model_Ship.m
//  BattleWar
//
//  Created by Bosko Petreski on 6/13/18.
//  Copyright © 2018 Bosko Petreski. All rights reserved.
//

#import "Model_Ship.h"
#import "Model_Field.h"

@implementation Model_Ship


-(Model_Ship *)initBoatSize:(NSInteger)boatSize field:(Model_Field *)field horisontal:(BOOL)isHorisontal grid:(NSArray *)grid{
    self = [super init];
    if (self) {
        self.boatSize = boatSize;
        self.isHorisontal = isHorisontal;
        
        NSMutableArray *arrFieldsToCheck = [NSMutableArray new];
        
        if(isHorisontal){
            for(NSInteger x = 0; x < boatSize ; x++){
                if(field.xPos + x >= grid.count){
                    Model_Field *newField = grid[field.xPos - (boatSize - x)][field.yPos];
                    [arrFieldsToCheck addObject:newField];
                }
                else{
                    Model_Field *newField = grid[field.xPos + x][field.yPos];
                    [arrFieldsToCheck addObject:newField];
                }
            }
        }
        else{
            for(NSInteger y = 0; y < boatSize ; y++){
                if(field.yPos + y >= grid.count){
                    Model_Field *newField = grid[field.xPos][field.yPos - (boatSize - y)];
                    [arrFieldsToCheck addObject:newField];
                }
                else{
                    Model_Field *newField = grid[field.xPos][field.yPos + y];
                    [arrFieldsToCheck addObject:newField];
                }
            }
        }
        
        if([self areFieldsEmpty:arrFieldsToCheck]){
            for(Model_Field *field in arrFieldsToCheck){
                field.ship = self;
                field.hasShip = YES;
                [field.buttonField setTitle:@"0"];
                field.buttonField.layer.backgroundColor = [NSColor blueColor].CGColor;
            }
            self.fields = arrFieldsToCheck;
            return self;
        }
    }
    return nil;
}
-(BOOL)isDesroyed{
    for(Model_Field *field in self.fields){
        if(!field.isClicked){
            return NO;
        }
    }
    return YES;
}
-(BOOL)areFieldsEmpty:(NSArray *)fields{
    for(Model_Field *field in fields){
        if(field.hasShip){
            return NO;
        }
    }
    return YES;
}

@end
