#import "AWS3Module.h"
#import <CoreServices/CoreServices.h>
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

@implementation AWS3Module

// Initialize the task dictionary
- (instancetype)init {
  if (self = [super init]) {
    self.tasks = [NSMutableDictionary dictionary];
  }
  return self;
}

// Expose to React Native
RCT_EXPORT_MODULE();

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

@try {
    
    // Setup AWS credentials
    AWSStaticCredentialsProvider *credentialsProvider = [[AWSStaticCredentialsProvider alloc] initWithAccessKey:accessKey secretKey:secretKey];
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:credentialsProvider];
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;

    // Ensure file URL is valid 
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    
    if (!fileURL) {

            NSDictionary *userInfo = @{
            @"workId": workId,
            @"status": @"Failed"
        };

        NSError *error = [NSError errorWithDomain:@"com.awss3"
                                              code:1000
                                          userInfo:userInfo];

        // Reject the promise with an error code, message, and details
        reject(@"1000", @"File not found.", error);
    
    return;

    }

    NSString *mimeType = [self getMimeTypeForFileAtPath:filePath];
    NSLog(@"MIME Type: %@", mimeType);

    // Create a Transfer Utility object
    AWSS3TransferUtility *transferUtility = [AWSS3TransferUtility defaultS3TransferUtility];
    
    // Start the upload
    [[transferUtility uploadFile:fileURL
                          bucket:bucketName
                             key:s3Key
                     contentType:mimeType
                      expression:nil
                completionHandler:^(AWSS3TransferUtilityUploadTask *task, NSError *error) {
                
        if (error) {
                    
            NSLog(@"Upload failed: %@", error.localizedDescription);

            // Return output to React Native
            NSDictionary *userInfo = @{
                @"workId": workId,
                @"status": @"Failed"
            };

            NSError *error = [NSError errorWithDomain:@"com.awss3"
                                                code:1001
                                            userInfo:userInfo];

            // Reject the promise with an error code, message, and details
            reject(@"1001", @"Upload work failed or was cancelled", error);

        } else {

            NSLog(@"Upload completed for key: %@", task.key);

            resolve(@{ @"workId": workId, @"status": @"Completed" });

        }
    }] continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
           NSLog(@"Failed to start upload: %@", task.error.localizedDescription);           
        }
        
        if ([task.result isKindOfClass:[AWSS3TransferUtilityUploadTask class]])
        {
             // Store the task with the workId
            AWSS3TransferUtilityUploadTask *uploadTask = (AWSS3TransferUtilityUploadTask *)task.result;

            if (uploadTask) {                
                 // Store the task with the custom workId
                [self.tasks setObject:uploadTask forKey:workId];                
                NSLog(@"Upload started for workId: %@", workId);               
            }
        }

        return nil;
    }];
}
@catch (NSException *exception) {
        NSLog(@"Caught exception: %@", exception.name);
        NSLog(@"Reason: %@", exception.reason);

        // Return output to React Native
        NSDictionary *userInfo = @{
            @"workId": workId,
            @"status": @"Failed",
            @"error": exception.reason
        };

        NSError *error = [NSError errorWithDomain:@"com.awss3"
                                              code:2001
                                          userInfo:userInfo];

        // Reject the promise with an error code, message, and details
        reject(@"2001", @"Error occurred in uploading work.", error);
    }
}

RCT_EXPORT_METHOD(getUploadStatus:(NSString *)workId
                         resolver:(RCTPromiseResolveBlock)resolve
                         rejecter:(RCTPromiseRejectBlock)reject) {

@try {

    NSLog(@"Get upload status for workId: %@", workId );
    
    AWSS3TransferUtilityUploadTask *task = self.tasks[workId];
    
    if (task) {
        NSString *statusString;
        
        switch (task.status) {
            case AWSS3TransferUtilityTransferStatusInProgress:
                statusString = @"In Progress";
                break;
            case AWSS3TransferUtilityTransferStatusPaused:
                statusString = @"Paused";
                break;
            case AWSS3TransferUtilityTransferStatusCompleted:
                statusString = @"Completed";
                break;
            case AWSS3TransferUtilityTransferStatusUnknown:
                statusString = @"Unknown";
                break;
            default:
                statusString = @"Unknown";
                break;
        }            
        
        resolve(@{ @"workId": workId, @"status": statusString });

    } else {

        // Return output to React Native
        NSDictionary *userInfo = @{
            @"workId": workId,
            @"status": @"NotFound"
        };

        NSError *error = [NSError errorWithDomain:@"com.awss3"
                                              code:1002
                                          userInfo:userInfo];

        // Reject the promise with an error code, message, and details
        reject(@"1002", @"No upload work found for the provided workId", error);

    }

    }
    @catch (NSException *exception) {
        NSLog(@"Caught exception: %@", exception.name);
        NSLog(@"Reason: %@", exception.reason);

        // Return output to React Native
        NSDictionary *userInfo = @{
            @"workId": workId,
            @"status": @"Failed",
            @"error": exception.reason
        };

        NSError *error = [NSError errorWithDomain:@"com.awss3"
                                              code:2002
                                          userInfo:userInfo];

        // Reject the promise with an error code, message, and details
        reject(@"2002", @"Error occurred while getting work status.", error);
    }
}

// Method to cancel the upload
RCT_EXPORT_METHOD(cancelUpload:(NSString *)workId
                      resolver:(RCTPromiseResolveBlock)resolve
                      rejecter:(RCTPromiseRejectBlock)reject) {

@try {

    AWSS3TransferUtilityUploadTask *task = self.tasks[workId];
    
    if (task) {
        
        // Cancel the upload task
        [self.tasks[workId] cancel];

        // Check if the task was successfully canceled
        if (self.tasks[workId].status == AWSS3TransferUtilityTransferStatusCancelled) {
            
            NSLog(@"Upload task for workId: %@ has been canceled", workId);

            // Return output to React Native
            NSDictionary *userInfo = @{
                @"workId": workId,
                @"status": @"Cancelled"
            };

            resolve(userInfo);
            
        } else {

            // Return output to React Native
            NSDictionary *userInfo = @{
                @"workId": workId,
                @"status": @"Failed"
            };

            NSError *error = [NSError errorWithDomain:@"com.awss3"
                                                code:1003
                                            userInfo:userInfo];

            // Reject the promise with an error code, message, and details
            reject(@"1003", @"No upload work found for the provided workId", error);
        }
    } else {
        // Return output to React Native
        NSDictionary *userInfo = @{
            @"workId": workId,
            @"status": @"NotFound"
        };

        NSError *error = [NSError errorWithDomain:@"com.awss3"
                                              code:1002
                                          userInfo:userInfo];

        // Reject the promise with an error code, message, and details
        reject(@"1002", @"No upload work found for the provided workId.", error);
    }

     }
    @catch (NSException *exception) {
        NSLog(@"Caught exception: %@", exception.name);
        NSLog(@"Reason: %@", exception.reason);

        // Return output to React Native
        NSDictionary *userInfo = @{
            @"workId": workId,
            @"status": @"Failed",
            @"error": exception.reason
        };

        NSError *error = [NSError errorWithDomain:@"com.awss3"
                                              code:2003
                                          userInfo:userInfo];

        // Reject the promise with an error code, message, and details
        reject(@"2003", @"Error occurred while cancelling upload work.", error);
    }
}

- (NSString *)getMimeTypeForFileAtPath:(NSString *)filePath {
    // Get the file extension
    NSString *fileExtension = [filePath pathExtension];
    
    // Check if iOS 14+ APIs are available
    if (@available(iOS 14.0, *)) {
        // Use UniformTypeIdentifiers framework
        UTType *fileUTType = [UTType typeWithFilenameExtension:fileExtension];
        NSString *mimeType = fileUTType.preferredMIMEType;
        return mimeType ?: @"application/octet-stream";
    } else {
        // Use MobileCoreServices for iOS < 14
        CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,
                                                                (__bridge CFStringRef)fileExtension,
                                                                NULL);
        NSString *mimeType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType);
        if (uti) CFRelease(uti);
        return mimeType ?: @"application/octet-stream";
    }
}

@end
