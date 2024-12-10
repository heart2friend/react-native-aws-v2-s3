#import <React/RCTBridgeModule.h>
#import <Foundation/Foundation.h>
#import <AWSS3/AWSS3.h>
#import <AWSCore/AWSCore.h>

@interface AWS3Module : NSObject <RCTBridgeModule>

@property (nonatomic, strong) NSMutableDictionary<NSString *, AWSS3TransferUtilityUploadTask *> *tasks;

- (void)uploadFileToS3:(NSString *)workId
            filePath:(NSString *)filePath
            bucketName:(NSString *)bucketName
            region:(NSString *)region
            accessKey:(NSString *)accessKey
            secretKey:(NSString *)secretKey
            s3Key:(NSString *)s3Key
            resolver:(RCTPromiseResolveBlock)resolve
            rejecter:(RCTPromiseRejectBlock)reject;

- (void)getUploadStatus:(NSString *)workId
            resolver:(RCTPromiseResolveBlock)resolve
            rejecter:(RCTPromiseRejectBlock)reject;

- (void)cancelUpload:(NSString *)workId
            resolver:(RCTPromiseResolveBlock)resolve
            rejecter:(RCTPromiseRejectBlock)reject;
@end
