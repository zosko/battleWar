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
    int boats_destroyed;
}

#pragma mark - CustomFunctions
-(void)generateMatrixView{
    matrixGrid = [NSMutableArray new];
    for(NSInteger i = 0; i < MATRIX_SIZE ; i++){
        NSMutableArray *tmpMatrix = [NSMutableArray new];
        for(NSInteger j = 0; j < MATRIX_SIZE ; j++){
            Model_Field *field = [Model_Field.alloc initField:i y:j];
            [tmpMatrix addObject:field];
        }
        [matrixGrid addObject:tmpMatrix];
    }
    
    for(NSInteger i = 0; i < MATRIX_SIZE ; i++){
        for(NSInteger j = 0; j < MATRIX_SIZE ; j++){
            Model_Field *field = matrixGrid[i][j];
            NSButton *btnField = [NSButton buttonWithTitle:[NSString stringWithFormat:@"%lu",i * MATRIX_SIZE + j] target:self action:@selector(fieldClicked:)];
            btnField.tag = i * MATRIX_SIZE + j;
            btnField.frame = CGRectMake(field.xPos * FIELD_SIZE, field.yPos * FIELD_SIZE, FIELD_SIZE, FIELD_SIZE);
            [btnField setBezelStyle:NSBezelStyleShadowlessSquare];
            NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:btnField.title attributes:@{NSForegroundColorAttributeName:[NSColor clearColor]}];
            [btnField setAttributedTitle:attrString];
            field.buttonField = btnField;
            
            NSTrackingArea* trackingArea = [[NSTrackingArea alloc] initWithRect:[btnField bounds]
                                                                        options:NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways
                                                                          owner:self userInfo:@{@"tag":@(btnField.tag)}];
            [btnField addTrackingArea:trackingArea];
            
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
            [btnField setBezelStyle:NSBezelStyleShadowlessSquare];
            
            NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:btnField.title attributes:@{NSForegroundColorAttributeName:[NSColor clearColor]}];
            [btnField setAttributedTitle:attrString];
            
            
            field.buttonField = btnField;
            [self.view addSubview:btnField];
        }
    }
}
-(NSString *)getLocalIPAddress{
    NSArray *ipAddresses = [[NSHost hostWithName:[[NSHost currentHost] name]] addresses];
    NSLog(@"%@",ipAddresses);
    for (NSString *ipAddress in ipAddresses) {
        if ([ipAddress componentsSeparatedByString:@"."].count == 4 && ![ipAddress hasPrefix:@"169"]) {
            return ipAddress;
        }
    }
    return @"Not Connected.";
}

#pragma mark - IBActions
-(IBAction)fieldClicked:(NSButton *)button{
    NSInteger i = button.tag / MATRIX_SIZE;
    NSInteger j = button.tag % MATRIX_SIZE;
    
    Model_Field *field = matrixGrid[i][j];
    if(!isStarted && !field.hasShip && shipToAdd > 0){
        Model_Ship *ship = [Model_Ship.alloc initBoatSize:shipToAdd field:field horisontal:isHorisontal grid:matrixGrid preview:NO];
        if(ship){
            [buttonAdd setHidden:YES];
            shipToAdd = 0;
        }
    }
}
-(IBAction)fieldOpponentClicked:(NSButton *)button{
    if(!isStarted) return;
    if(!isYourTurn) return;
    isYourTurn = NO;
    lblTurn.stringValue = @"Opponent turn";
    [button setEnabled:NO];
    [udpSocket sendData:[button.title dataUsingEncoding:NSUTF8StringEncoding] toHost:strOpponentIpAddress port:31337 withTimeout:-1 tag:0];
    button.title = @"";
    button.layer.backgroundColor = [NSColor lightGrayColor].CGColor;
}
-(IBAction)onBtnAddShip:(NSButton *)sender{
    shipToAdd = sender.title.integerValue;
    buttonAdd = sender;
}
-(IBAction)onBtnHorisontal:(NSButton *)sender{
    isHorisontal = !sender.tag;
}
-(IBAction)onBtnStart:(NSButton *)sender{
    [sender setHidden:YES];
    isStarted = YES;
    isYourTurn = YES;
    lblTurn.stringValue = @"Waiting opponent";
    [udpSocket sendData:[[NSString stringWithFormat:@"ready %@",strMineIpAddress] dataUsingEncoding:NSUTF8StringEncoding] toHost:@"255.255.255.255" port:31337 withTimeout:-1 tag:0];
}

#pragma mark - MouseHoverEvent
-(void)mouseEntered:(NSEvent *)theEvent{
    if(isStarted) return;
    
    NSInteger btnTag = [theEvent.trackingArea.userInfo[@"tag"] integerValue];
    NSInteger i = btnTag / MATRIX_SIZE;
    NSInteger j = btnTag % MATRIX_SIZE;
    
    Model_Field *field = matrixGrid[i][j];
    if(!field.hasShip && shipToAdd > 0){
        Model_Ship *ship = [Model_Ship.alloc initBoatSize:shipToAdd field:field horisontal:isHorisontal grid:matrixGrid preview:YES];
        if(ship){}
    }
}
-(void)mouseExited:(NSEvent *)theEvent{
    if(isStarted) return;
    
    NSInteger btnTag = [theEvent.trackingArea.userInfo[@"tag"] integerValue];
    NSInteger i = btnTag / MATRIX_SIZE;
    NSInteger j = btnTag % MATRIX_SIZE;
    
    Model_Field *field = matrixGrid[i][j];
    Model_Ship *ship = [Model_Ship.alloc initBoatSize:shipToAdd field:field horisontal:isHorisontal grid:matrixGrid preview:YES];
    if(ship){}
}

#pragma mark - Sockets
-(void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    NSString *bombRecv = [NSString.alloc initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@",bombRecv);
    
    if([bombRecv containsString:@"ready"]){
        NSString *opponentIpAddress = [[bombRecv componentsSeparatedByString:@" "] lastObject];
        if(![strMineIpAddress isEqualToString:opponentIpAddress]){
            strOpponentIpAddress = opponentIpAddress;
        }
        return;
    }
    
    if(!isStarted) return;
    if([bombRecv containsString:@"hit"]){
        bombRecv = [[bombRecv componentsSeparatedByString:@" "] firstObject];
        NSInteger i = bombRecv.integerValue / MATRIX_SIZE;
        NSInteger j = bombRecv.integerValue % MATRIX_SIZE;
        Model_Field *field = matrixOpponentGrid[i][j];
        field.buttonField.layer.backgroundColor = [NSColor redColor].CGColor;
        field.buttonField.title = @"";
        [field.buttonField setHidden:NO];
        isYourTurn = YES;
        lblTurn.stringValue = @"Your turn";
        return;
    }
    if([bombRecv containsString:@"destroyed"]){
        NSAlert *alert = [NSAlert new];
        [alert setMessageText:bombRecv];
        [alert addButtonWithTitle:@"OK"];
        [alert beginSheetModalForWindow:self.view.window completionHandler:nil];
        
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
        field.buttonField.title = @"";
        field.buttonField.layer.backgroundColor = [NSColor redColor].CGColor;
        if([field.ship isDesroyed]){
            NSString *boatName = [NSString stringWithFormat:@"%@ hit",bombRecv];
            [udpSocket sendData:[boatName dataUsingEncoding:NSUTF8StringEncoding] toHost:strOpponentIpAddress port:31337 withTimeout:-1 tag:0];
            
            boatName = [NSString stringWithFormat:@"%@ destroyed",@[@"boat",@"boat",@"boat",@"boat",@"boat",@"boat"][field.ship.boatSize]];
            [udpSocket sendData:[boatName dataUsingEncoding:NSUTF8StringEncoding] toHost:strOpponentIpAddress port:31337 withTimeout:-1 tag:0];
            boats_destroyed++;
            [[NSSound soundNamed:@"bomb"] play];
        }
        else{
            [[NSSound soundNamed:@"Glass"] play];
            NSString *boatName = [NSString stringWithFormat:@"%@ hit",bombRecv];
            [udpSocket sendData:[boatName dataUsingEncoding:NSUTF8StringEncoding] toHost:strOpponentIpAddress port:31337 withTimeout:-1 tag:0];
        }
        
        if(boats_destroyed >= 4){
            NSAlert *alert = [NSAlert new];
            [alert setMessageText:@"YOU LOOSE"];
            [alert addButtonWithTitle:@"OK"];
            [alert beginSheetModalForWindow:self.view.window completionHandler:nil];
        }
    }
    else{
        [field.buttonField setEnabled:NO];
        field.buttonField.title = @"";
        field.buttonField.layer.backgroundColor = [NSColor lightGrayColor].CGColor;
    }
}

#pragma mark - UIViewDelegates
-(void)viewDidLoad {
    [super viewDidLoad];
    [self generateMatrixView];
    [self generateOpponentMatrixView];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
       self->strMineIpAddress = self.getLocalIPAddress;
    }];
    
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
    if ([udpSocket enableBroadcast:YES error:&error] == false) {
        NSLog(@"Failed to enable broadcast, Reason : %@",[error userInfo]);
    }
}
-(void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}

@end
