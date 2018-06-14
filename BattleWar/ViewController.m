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
    NSMutableArray *matrixOpponentGrid;
    NSInteger shipToAdd;
    BOOL isHorisontal;
    NSButton *buttonAdd;
    BOOL isStarted;
    BOOL isYourTurn;
}

-(void)fieldClicked:(NSButton *)button{
    NSInteger i = button.tag / MATRIX_SIZE;
    NSInteger j = button.tag % MATRIX_SIZE;
    
    Model_Field *field = matrixGrid[i][j];
    if(!isStarted && !field.hasShip && shipToAdd > 0){
        Model_Ship *ship = [Model_Ship.alloc initBoatSize:shipToAdd field:field horisontal:isHorisontal grid:matrixGrid];
        if(ship){
            [buttonAdd setHidden:YES];
            shipToAdd = 0;
        }
    }
}
-(void)fieldOpponentClicked:(NSButton *)button{
    if(!isStarted) return;
    if(!isYourTurn) return;
    isYourTurn = NO;
    lblTurn.stringValue = @"Opponent turn";
    [button setHidden:YES];
    [udpSocket sendData:[button.title dataUsingEncoding:NSUTF8StringEncoding] toHost:txtIPAddress.stringValue port:31337 withTimeout:-1 tag:0];
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
    isYourTurn = YES;
    lblTurn.stringValue = @"Your turn";
    udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *error = nil;
    
    if (![udpSocket bindToPort:31337 error:&error]){
        NSLog(@"Error binding: %@", error);
        return;
    }
    if (![udpSocket beginReceiving:&error]){
        NSLog(@"Error receiving: %@", error);
        return;
    }
    
    NSLog(@"CHECK IP ADDRESS with ifconfig | grep 192.168 ");
}
-(void)viewDidLoad {
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
    [self generateOpponentMatrixView];
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
-(void)generateOpponentMatrixView{
    
    matrixOpponentGrid = [NSMutableArray new];
    
    for(NSInteger i = 0; i < MATRIX_SIZE ; i++){
        NSMutableArray *tmpMatrix = [NSMutableArray new];
        for(NSInteger j = 0; j < MATRIX_SIZE ; j++){
            Model_Field *field = [Model_Field.alloc initField:i y:j];
            [tmpMatrix addObject:field];
        }
        [matrixOpponentGrid addObject:tmpMatrix];
    }
    
    for(NSInteger i = 0; i < MATRIX_SIZE ; i++){
        for(NSInteger j = 0; j < MATRIX_SIZE ; j++){
            Model_Field *field = matrixOpponentGrid[i][j];
            NSButton *btnField = [NSButton buttonWithTitle:[NSString stringWithFormat:@"%lu",i * MATRIX_SIZE + j] target:self action:@selector(fieldOpponentClicked:)];
            btnField.tag = i * MATRIX_SIZE + j;
            btnField.frame = CGRectMake(700 + field.xPos * FIELD_SIZE, field.yPos * FIELD_SIZE, FIELD_SIZE, FIELD_SIZE);
            field.buttonField = btnField;
            
            [self.view addSubview:btnField];
        }
    }
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}


#pragma mark - Sockets
-(void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    NSString *bombRecv = [NSString.alloc initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"bombRecv: %@",bombRecv);
    if(!isStarted) return;
    if([bombRecv containsString:@"pogodi"]){
        bombRecv = [[bombRecv componentsSeparatedByString:@" "] firstObject];
        NSInteger i = bombRecv.integerValue / MATRIX_SIZE;
        NSInteger j = bombRecv.integerValue % MATRIX_SIZE;
        Model_Field *field = matrixOpponentGrid[i][j];
        field.buttonField.layer.backgroundColor = [NSColor redColor].CGColor;
        [field.buttonField setHidden:NO];
        isYourTurn = YES;
        lblTurn.stringValue = @"Your turn";
        return;
    }
    if([bombRecv containsString:@"unisteno"]){
        NSAlert *alert = [NSAlert new];
        [alert setMessageText:bombRecv];
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];
        isYourTurn = NO;
        lblTurn.stringValue = @"Opponent turn";
        return;
    }
    
    isYourTurn = YES;
    lblTurn.stringValue = @"Your turn";
    NSInteger i = bombRecv.integerValue / MATRIX_SIZE;
    NSInteger j = bombRecv.integerValue % MATRIX_SIZE;
    
    Model_Field *field = matrixGrid[i][j];
    field.isClicked = YES;
    if(field.hasShip){
        [field.buttonField setEnabled:NO];
        field.buttonField.layer.backgroundColor = [NSColor redColor].CGColor;
        if([field.ship isDesroyed]){
            NSString *boatName = [NSString stringWithFormat:@"%@ pogodi",bombRecv];
            [udpSocket sendData:[boatName dataUsingEncoding:NSUTF8StringEncoding] toHost:txtIPAddress.stringValue port:31337 withTimeout:-1 tag:0];
            
            boatName = [NSString stringWithFormat:@"%@ unisteno",@[@"poseidon",@"spiun",@"kajce",@"penta",@"traekt",@"tanker"][field.ship.boatSize]];
            [udpSocket sendData:[boatName dataUsingEncoding:NSUTF8StringEncoding] toHost:txtIPAddress.stringValue port:31337 withTimeout:-1 tag:0];
        }
        else{
            NSString *boatName = [NSString stringWithFormat:@"%@ pogodi",bombRecv];
            [udpSocket sendData:[boatName dataUsingEncoding:NSUTF8StringEncoding] toHost:txtIPAddress.stringValue port:31337 withTimeout:-1 tag:0];
        }
    }
    else{
        [field.buttonField setHidden:YES];
    }
}

@end
