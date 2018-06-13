//
//  ViewController.m
//  BattleWar
//
//  Created by Bosko Petreski on 6/13/18.
//  Copyright © 2018 Bosko Petreski. All rights reserved.
//

#import "ViewController.h"
#import "Model_Field.h"
#import "Model_Ship.h"

#define MATRIX_SIZE 10
#define FIELD_SIZE 50

@implementation ViewController{
    NSMutableArray *matrixGrid;
    NSInteger shipToAdd;
    BOOL isHorisontal;
    NSButton *buttonAdd;
    BOOL isStarted;
}

-(void)fieldClicked:(NSButton *)button{
    NSInteger i = button.tag / MATRIX_SIZE;
    NSInteger j = button.tag % MATRIX_SIZE;
    
    Model_Field *field = matrixGrid[i][j];
    if(isStarted){
        field.isClicked = YES;
        [field.buttonField setEnabled:NO];
        if(field.hasShip){
            field.buttonField.layer.backgroundColor = [NSColor redColor].CGColor;
            if([field.ship isDesroyed]){
                NSLog(@"WAAAAAAAAAAW");
            }
        }
    }
    else{
        if(!field.hasShip && shipToAdd > 0){
            Model_Ship *ship = [Model_Ship.alloc initBoatSize:shipToAdd field:field horisontal:isHorisontal grid:matrixGrid];
            if(ship){
                [buttonAdd setEnabled:NO];
                shipToAdd = 0;
            }
        }
    }
}
-(IBAction)onBtnAddShip:(NSButton *)sender{
    shipToAdd = sender.title.integerValue;
    buttonAdd = sender;
}
-(IBAction)onBtnHorisontal:(NSButton *)sender{
    isHorisontal = !sender.tag;
}
-(IBAction)onBtnStart:(NSButton *)sender{
    isStarted = YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    matrixGrid = [NSMutableArray new];
    shipToAdd = 0;
    
    for(NSInteger i = 0; i < MATRIX_SIZE ; i++){
        NSMutableArray *tmpMatrix = [NSMutableArray new];
        for(NSInteger j = 0; j < MATRIX_SIZE ; j++){
            Model_Field *field = [Model_Field.alloc initField:i y:j];
            [tmpMatrix addObject:field];
        }
        [matrixGrid addObject:tmpMatrix];
    }
    
    [self generateMatrixView];
}

-(void)generateMatrixView{
    for(NSInteger i = 0; i < MATRIX_SIZE ; i++){
        for(NSInteger j = 0; j < MATRIX_SIZE ; j++){
            Model_Field *field = matrixGrid[i][j];
            NSButton *btnField = [NSButton buttonWithTitle:[NSString stringWithFormat:@"%lu",i * MATRIX_SIZE + j] target:self action:@selector(fieldClicked:)];
            btnField.tag = i * MATRIX_SIZE + j;
            btnField.frame = CGRectMake(field.xPos * FIELD_SIZE, field.yPos * FIELD_SIZE, FIELD_SIZE, FIELD_SIZE);
            field.buttonField = btnField;
            
            [self.view addSubview:btnField];
        }
    }
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}


@end
