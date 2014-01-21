//
//  ViewController.m
//  FacebookReadFeed
//
//  Created by SDT-1 on 2014. 1. 21..
//  Copyright (c) 2014년 T. All rights reserved.
//

#import "ViewController.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>

#define FACEBOOK_APPID @"344325922372478"


@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (strong,nonatomic)NSArray *data;
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (strong,nonatomic)ACAccount *facebookAccount;
@end

@implementation ViewController


- (void)showTimeLine
{
    ACAccountStore *store = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    NSDictionary *options = @{ACFacebookAppIdKey:FACEBOOK_APPID,
                              ACFacebookPermissionsKey:@[@"read_stream"],
                              ACFacebookAudienceKey:ACFacebookAudienceEveryone};
    [store requestAccessToAccountsWithType:accountType options:options completion:^(BOOL granted, NSError *error) {
        if (error) {
            NSLog(@"Error:%@", error);
        }
        if (granted) {
            NSLog(@"권한 승인 성공");
            NSArray *accountList = [store accountsWithAccountType:accountType];
            self.facebookAccount = [accountList lastObject];
            
            [self requestFeed];
        }
        else
        {
            NSLog(@"권한 승인 실패");
        }
    }];
}


//- (void)showTimeLine{
//    ACAccountStore *store = [[ACAccountStore alloc] init];
//    ACAccountType *accountType = [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
//    
//    
//    NSDictionary *options = @{ACFacebookAppIdKey: FACEBOOK_APPID,
//                              ACFacebookPermissionsKey: @[@"read_stream"],
//                              ACFacebookAudienceKey:ACFacebookAudienceEveryone};
//    [store requestAccessToAccountsWithType:accountType options:options completion:^(BOOL granted,NSError *error){
//        if(error){
//            NSLog(@"error %@",error);
//        }
//        if(granted){
//            NSArray *accounts = [store accountsWithAccountType:accountType];
//            self.facebookAccount = [accounts lastObject];
//            [self requestFeed];
//        }
//        else{
//            NSLog(@"fall %@",error);
//        }
//    }];
//}


//- (void)requestFeed
//{
//    NSString *urlStr = @"https://graph.facebook.com/me/feed";
//    NSURL *url = [NSURL URLWithString:urlStr];
//    NSDictionary *params = nil;
//    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodGET URL:url parameters:params];
//    request.account = self.facebookAccount;
//    
//    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
//        if (error != nil) {
//            NSLog(@"Error : %@", error);
//            return;
//        }
//        
//        __autoreleasing NSError *parseError;
//        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&parseError];
//        
//        self.data = result[@"data"];
//        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//            [self.table reloadData];
//        }];
//    }];
//}


- (void)requestFeed{
    NSURL *url = [NSURL URLWithString:@"https://graph.facebook.com/me/feed"];
    NSDictionary *param = nil;
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodGET URL:url parameters:param];
    request.account = self.facebookAccount;
    
    [request performRequestWithHandler:^(NSData *responseData,NSHTTPURLResponse *urlResponse,NSError *error){
        if(nil != error){
            NSLog(@"실패 %@",error);
            return ;
        }
        
        __autoreleasing NSError *parseError = nil;
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&parseError];
        self.data = result[@"data"];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.table reloadData];
        }];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELL"];
    NSDictionary *one = self.data[indexPath.row];
    
    NSString *contents;
    if(one[@"message"]){
        NSDictionary *likes = one[@"likes"];
        NSArray *data = likes[@"data"];
       // NSLog(@"message likes %@ - %@",likes,count);
        contents = [NSString stringWithFormat:@" %@ ...(%d)",one[@"message"],[data count]];
    }
    else{
        contents = one[@"story"];
        cell.indentationLevel = 2;
    }
    cell.textLabel.text = contents;
    
    return cell;
}
- (void)viewWillAppear:(BOOL)animated{
    [self showTimeLine];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
