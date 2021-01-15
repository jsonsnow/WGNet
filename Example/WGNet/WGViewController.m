//
//  WGViewController.m
//  WGNet
//
//  Created by jsonsnow on 01/14/2021.
//  Copyright (c) 2021 jsonsnow. All rights reserved.
//

#import "WGViewController.h"
#import <WGNet/WGNet-Swift.h>

@interface WGViewController ()

@end

@implementation WGViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
     NSDictionary *dict = @{@"client_type":@"ios",@"platform":@"app",@"version":@"2.8.23",@"channel":@"enterprise"};
    NSDictionary *headers = @{@"wego-albumID": @"",
                              @"wego-channel": @"ios",
                              @"wego-version": @"2.8.23",
                              @"wego-staging": @"0"};
    
    [[NetLayer net] configDefaultParams:dict];
    [[NetLayer net] configDefaultHeaders:headers];
    [[NetLayer net] albumRequstWithPath:@"service/sys/sys_config.jsp" params:@{@"act":@"get_ios_config"} callback:^(WGConnectData * _Nonnull data) {
        
    }];
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
