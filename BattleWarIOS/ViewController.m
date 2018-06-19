//
//  ViewController.m
//  BattleWarIOS
//
//  Created by Bosko Petreski on 6/19/18.
//  Copyright © 2018 Bosko Petreski. All rights reserved.
//

#import "ViewController.h"
#import "Model_Field.h"
#import "Model_Ship.h"
#include <ifaddrs.h>
#include <arpa/inet.h>

#import <AVFoundation/AVFoundation.h>

#define MATRIX_SIZE 10
#define FIELD_SIZE 30

@interface ViewController (){
    NSMutableArray *matrixGrid;
    NSMutableArray *matrixOpponentGrid;
    NSInteger shipToAdd;
    BOOL isHorisontal;
    UIButton *buttonAdd;
    BOOL isStarted;
    BOOL isYourTurn;
    int boats_destroyed;
}

@end

@implementation ViewController

#pragma mark - CustomFunctions
-(void)restartGame{
    //TODO: MAKE RESTART GAME
}
- (void)playSound :(NSString *)fName{
    SystemSoundID audioEffect;
    NSString *path = [[NSBundle mainBundle] pathForResource : fName ofType :@"wav"];
    if ([[NSFileManager defaultManager] fileExistsAtPath : path]) {
        NSURL *pathURL = [NSURL fileURLWithPath: path];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef) pathURL, &audioEffect);
        AudioServicesPlaySystemSound(audioEffect);
    }
    else {
        NSLog(@"error, file not found: %@", path);
    }
}
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
            UIButton *btnField = [UIButton buttonWithType:UIButtonTypeSystem];
            btnField.titleLabel.text = [NSString stringWithFormat:@"%lu",i * MATRIX_SIZE + j];
            btnField.titleLabel.textColor = UIColor.clearColor;
            btnField.layer.borderColor = UIColor.blackColor.CGColor;
            btnField.layer.borderWidth = 1;
            [btnField addTarget:self action:@selector(fieldClicked:) forControlEvents:UIControlEventTouchUpInside];
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
            UIButton *btnField = [UIButton buttonWithType:UIButtonTypeSystem];
            btnField.titleLabel.text = [NSString stringWithFormat:@"%lu",i * MATRIX_SIZE + j];
            btnField.titleLabel.textColor = UIColor.clearColor;
            btnField.layer.borderColor = UIColor.blackColor.CGColor;
            btnField.layer.borderWidth = 1;
            [btnField addTarget:self action:@selector(fieldOpponentClicked:) forControlEvents:UIControlEventTouchUpInside];
            btnField.tag = i * MATRIX_SIZE + j;
            btnField.frame = CGRectMake(350 + field.xPos * FIELD_SIZE, field.yPos * FIELD_SIZE, FIELD_SIZE, FIELD_SIZE);
            field.buttonField = btnField;
            [self.view addSubview:btnField];
        }
    }
}
-(NSString *)getLocalIPAddress{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    
                }
                
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

#pragma mark - IBActions
-(IBAction)fieldClicked:(UIButton *)button{
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
-(IBAction)fieldOpponentClicked:(UIButton *)button{
    if(!isStarted) return;
    if(!isYourTurn) return;
    isYourTurn = NO;
    lblTurn.text = @"Opponent turn";
    [button setEnabled:NO];
    [udpSocket sendData:[button.titleLabel.text dataUsingEncoding:NSUTF8StringEncoding] toHost:strOpponentIpAddress port:31337 withTimeout:-1 tag:0];
    button.titleLabel.text = @"";
    [button setBackgroundColor:[UIColor lightGrayColor]];
}
-(IBAction)onBtnAddShip:(UIButton *)sender{
    shipToAdd = sender.titleLabel.text.integerValue;
    buttonAdd = sender;
}
-(IBAction)onBtnHorisontal:(UIButton *)sender{
    isHorisontal = !sender.tag;
}
-(IBAction)onBtnStart:(UIButton *)sender{
    [sender setHidden:YES];
    isStarted = YES;
    isYourTurn = YES;
    lblTurn.text = @"Waiting opponent";
    [udpSocket sendData:[[NSString stringWithFormat:@"ready %@",strMineIpAddress] dataUsingEncoding:NSUTF8StringEncoding] toHost:@"255.255.255.255" port:31337 withTimeout:-1 tag:0];
}

#pragma mark - Sockets
-(void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    NSString *bombRecv = [NSString.alloc initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@",bombRecv);
    
    if([bombRecv containsString:@"ready"]){
        NSString *opponentIpAddress = [[bombRecv componentsSeparatedByString:@" "] lastObject];
        if(![strMineIpAddress isEqualToString:opponentIpAddress]){
            strOpponentIpAddress = opponentIpAddress;
            lblTurn.text = @"Game started";
        }
        return;
    }
    
    if(!isStarted) return;
    if([bombRecv containsString:@"hit"]){
        [self playSound:@"Glass"];
        
        bombRecv = [[bombRecv componentsSeparatedByString:@" "] firstObject];
        NSInteger i = bombRecv.integerValue / MATRIX_SIZE;
        NSInteger j = bombRecv.integerValue % MATRIX_SIZE;
        Model_Field *field = matrixOpponentGrid[i][j];
        [field.buttonField setBackgroundColor:[UIColor redColor]];
        field.buttonField.titleLabel.text = @"";
        [field.buttonField setHidden:NO];
        isYourTurn = YES;
        lblTurn.text = @"Your turn";
        return;
    }
    if([bombRecv containsString:@"destroyed"]){
        [self playSound:@"bomb"];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:bombRecv preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        
        isYourTurn = NO;
        lblTurn.text = @"Opponent turn";
        return;
    }
    if([bombRecv containsString:@"victory"]){
        [self playSound:@"victory"];
    }
    
    isYourTurn = YES;
    lblTurn.text = @"Your turn";
    NSInteger i = bombRecv.integerValue / MATRIX_SIZE;
    NSInteger j = bombRecv.integerValue % MATRIX_SIZE;
    
    Model_Field *field = matrixGrid[i][j];
    field.isClicked = YES;
    if(field.hasShip){
        [field.buttonField setEnabled:NO];
        field.buttonField.titleLabel.text = @"";
        [field.buttonField setBackgroundColor:[UIColor redColor]];
        if([field.ship isDesroyed]){
            NSString *boatName = [NSString stringWithFormat:@"%@ hit",bombRecv];
            [udpSocket sendData:[boatName dataUsingEncoding:NSUTF8StringEncoding] toHost:strOpponentIpAddress port:31337 withTimeout:-1 tag:0];
            
            boatName = [NSString stringWithFormat:@"%@ destroyed",@[@"Ghost Boat",@"Lifeboat",@"Patrol Boat",@"Destroyer",@"Submarine",@"Aircraft Carrier"][field.ship.boatSize]];
            [udpSocket sendData:[boatName dataUsingEncoding:NSUTF8StringEncoding] toHost:strOpponentIpAddress port:31337 withTimeout:-1 tag:0];
            boats_destroyed++;
            
            [self playSound:@"bomb"];
        }
        else{
            [self playSound:@"Glass"];
            NSString *boatName = [NSString stringWithFormat:@"%@ hit",bombRecv];
            [udpSocket sendData:[boatName dataUsingEncoding:NSUTF8StringEncoding] toHost:strOpponentIpAddress port:31337 withTimeout:-1 tag:0];
        }
        
        if(boats_destroyed >= 4){
            [udpSocket sendData:[@"victory" dataUsingEncoding:NSUTF8StringEncoding] toHost:strOpponentIpAddress port:31337 withTimeout:-1 tag:0];
            [self playSound:@"looser"];
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"YOU LOOSE" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
    else{
        [field.buttonField setEnabled:NO];
        field.buttonField.titleLabel.text = @"";
        [field.buttonField setBackgroundColor:[UIColor lightGrayColor]];
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
-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
