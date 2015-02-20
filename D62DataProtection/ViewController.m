//
//  ViewController.m
//  D62DataProtection
//
//  Created by Rommel Rico on 2/19/15.
//  Copyright (c) 2015 Rommel Rico. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextView *myTextView;

@end

@implementation ViewController

- (NSString *)normalPath {
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/file.txt"];
}

- (NSString *)encryptedPath {
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/file.dat"];
}

- (IBAction)doSaveNormal:(id)sender {
    [self.myTextView.text writeToFile:[self normalPath] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    self.myTextView.text = @"Data Written Normally!";
}

- (IBAction)doReadNormal:(id)sender {
    self.myTextView.text = [NSString stringWithContentsOfFile:[self normalPath] encoding:NSUTF8StringEncoding error:nil];
}

- (IBAction)doSaveEncrypted:(id)sender {
    NSData *data = [self.myTextView.text dataUsingEncoding:NSUTF8StringEncoding];
    [data writeToFile:[self encryptedPath] options:NSDataWritingFileProtectionComplete error:nil];
    self.myTextView.text = @"Data Written with Encryption!";
}

- (IBAction)doReadEncrypted:(id)sender {
    NSData *data = [NSData dataWithContentsOfFile:[self encryptedPath] options:0 error:nil];
    self.myTextView.text = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
}

- (IBAction)doReadEncryptedNormal:(id)sender {
    //Start a background operation --- also remind user to lock phone.
    [[[UIAlertView alloc] initWithTitle:@"Note" message:@"Lock phone now!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    UIBackgroundTaskIdentifier taskID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSLog(@"Before sleep");
        sleep(20); //Sleep long enough for file encryption to work.
        NSLog(@"After sleep");
        NSError *myError = nil;
        NSData *data = [NSData dataWithContentsOfFile:[self encryptedPath] options:0 error:&myError];
        if (myError) {
            NSLog(@"%@", myError);
        } else {
            NSLog(@"Success!");
            //self.myTextView.text =[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]; Needs to run on main thread.
        }
        [[UIApplication sharedApplication] endBackgroundTask:taskID];
    });
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doDataBecomeAvailable) name:UIApplicationProtectedDataDidBecomeAvailable object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doDataBecomeUnavailable) name:UIApplicationProtectedDataWillBecomeUnavailable object:nil];
}

- (void)doDataBecomeAvailable {
    NSLog(@"%s", __func__);
}

- (void)doDataBecomeUnavailable {
    NSLog(@"%s", __func__);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
