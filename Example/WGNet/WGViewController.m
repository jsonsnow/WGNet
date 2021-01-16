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
     NSDictionary *dict = @{@"client_type":@"ios",
                            @"platform":@"app",
                            @"version":@"2823",
                            @"channel":@"enterprise",
                            @"system_version":@"13.4.1",
                            @"token":@"OTRGOTRDRDUyOEQ4Qjg3Nzc5RjlDNUQxRjIxRTQ2QzcwQjI1QkUxRkNBRUI4QTA1RjVDNERBQTY0MUYwRkM2RDgzQUYwRDcwRkNCMUEzRkMxMjNBOEJERTVBMjYxNEI2"
     };
    NSDictionary *headers = @{@"wego-albumID": @"",
                              @"wego-channel": @"ios",
                              @"wego-version": @"2823",
                              @"wego-staging": @"0",
                              
    };
    //统一配置共用信息
    [[NetLayer net] configDefaultParams:dict];
    //配置共用头
    [[NetLayer net] configDefaultHeaders:headers];
    
    [[NetLayer net] albumRequstWithPath:@"service/sys/sys_config.jsp" params:@{@"act": @"get_ios_config"} callback:^(WGConnectData * _Nonnull data) {
        
    }];
    [[NetLayer net] albumRequstWithPath:@"album/personal/all" params:@{@"albumId": @"A201903020936258040206326"} callback:^(WGConnectData * _Nonnull data) {
        
    }];
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
