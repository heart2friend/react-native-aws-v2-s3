#import <React/RCTBridgeModule.h>
#import <Foundation/Foundation.h>

@interface RCT_EXTERN_MODULE(AWS3Module, NSObject)

RCT_EXTERN_METHOD(uploadFileToS3:(NSString *)workId
            filePath:(NSString *)filePath
            bucketName:(NSString *)bucketName
            region:(NSString *)region
            accessKey:(NSString *)accessKey
            secretKey:(NSString *)secretKey
            s3Key:(NSString *)s3Key
            resolver:(RCTPromiseResolveBlock)resolve
            rejecter:(RCTPromiseRejectBlock)reject);

@end