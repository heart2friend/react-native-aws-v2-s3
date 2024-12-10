#import "AWS3Module.h"
#import <AWSS3/AWSS3.h>
#import <AWSCore/AWSCore.h>

@implementation AWS3Module

RCT_EXPORT_METHOD(uploadFileToS3:(NSString *)workId
                    filePath:(NSString *)filePath
                    bucketName:(NSString *)bucketName
                    region:(NSString *)region
                    accessKey:(NSString *)accessKey
                    secretKey:(NSString *)secretKey
                    s3Key:(NSString *)s3Key
                    resolver:(RCTPromiseResolveBlock)resolve
                    rejecter:(RCTPromiseRejectBlock)reject)
        {

    // Setup AWS credentials
    AWSStaticCredentialsProvider *credentialsProvider = [[AWSStaticCredentialsProvider alloc] initWithAccessKey:accessKey secretKey:secretKey];
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:credentialsProvider];
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;

    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    
    // Create a Transfer Utility object
    AWSS3TransferUtility *transferUtility = [AWSS3TransferUtility defaultS3TransferUtility];
    
    // Start the upload
    [[transferUtility uploadFile:fileURL
                          bucket:bucketName
                             key:s3Key
                     contentType:@"application/pdf"
                      expression:nil
                completionHandler:^(AWSS3TransferUtilityUploadTask *task, NSError *error) {
        if (error) {
            NSLog(@"Upload failed with error: %@", error);
        } else {
            NSLog(@"Upload successful!");
        }
    }] continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
            NSLog(@"Error: %@", task.error);
        }
        if (task.result) {
            NSLog(@"Upload started...");
        }
        return nil;
    }];

}

@end