declare module 'react-native-aws-s3' {
  export function uploadFile(
    workId: string,
    filePath: string,
    s3Key: string,
    bucketName: string,
    accessKey: string,
    secreteKey: string,
    region: string
  ): Promise<any>;

  export function getUploadStatus(workId: string): Promise<any>;

  export function cancelUpload(workId: string): Promise<any>;
}
