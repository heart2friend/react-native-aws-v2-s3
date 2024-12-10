#import "AWS3Module.h"

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

    // Setup AWS credentials
    AWSStaticCredentialsProvider *credentialsProvider = [[AWSStaticCredentialsProvider alloc] initWithAccessKey:accessKey secretKey:secretKey];
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:credentialsProvider];
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;

    // Ensure file URL is valid
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    
    if (!fileURL) {
    reject(@"invalid_file", @"The file path is invalid.", nil);
    return;
    }

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
                    NSLog(@"Upload failed: %@", error.localizedDescription);
                    reject(@"upload_failed", @"Upload failed", error);
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

RCT_EXPORT_METHOD(getUploadStatus:(NSString *)workId
                         resolver:(RCTPromiseResolveBlock)resolve
                         rejecter:(RCTPromiseRejectBlock)reject) {

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
        reject(@"task_not_found", @"No upload task found for the provided workId", nil);
    }
}

// Method to cancel the upload
RCT_EXPORT_METHOD(cancelUpload:(NSString *)workId
                      resolver:(RCTPromiseResolveBlock)resolve
                      rejecter:(RCTPromiseRejectBlock)reject) {

    AWSS3TransferUtilityUploadTask *task = self.tasks[workId];
    
    if (task) {
        
        // Cancel the upload task
        [self.tasks[workId] cancel];

        // Check if the task was successfully canceled
        if (self.tasks[workId].status == AWSS3TransferUtilityTransferStatusCancelled) {
            
            NSLog(@"Upload task for workId: %@ has been canceled", workId);
            resolve(@{ @"workId": workId, @"status": @"Cancelled" });
            
        } else {
            NSError *error = [NSError errorWithDomain:@"com.aws.s3"
                                                 code:1001
                                             userInfo:@{NSLocalizedDescriptionKey: @"Failed to cancel upload"}];
            reject(@"cancel_failed", @"Failed to cancel the upload", error);
        }
    } else {
        NSError *error = [NSError errorWithDomain:@"com.aws.s3"
                                             code:1002
                                         userInfo:@{NSLocalizedDescriptionKey: @"No ongoing upload task found"}];
        reject(@"no_upload_task", @"No upload task found to cancel", error);
    }
}

@end
