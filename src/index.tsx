import { NativeModules } from 'react-native';

const { AWS3Module } = NativeModules;

export interface AS3CredentialsType {
  bucketName: string,
  accessKey: string,
  secreteKey: string,
  region: string
}

export const uploadFile = (
  workId: string,
  filePath: string,
  s3Key: string,
  as3credentials : AS3CredentialsType

) => {
  try {
    return AWS3Module.uploadFileToS3(
      workId,
      filePath,
      as3credentials.bucketName,
      as3credentials.region,
      as3credentials.accessKey,
      as3credentials.secreteKey,
      s3Key
    );
  } catch (error) {
    console.error('Error from AWSS3:', error);
    return error;
  }
};

export const getUploadStatus = (workId: string) => {
  try {
    return AWS3Module.getUploadStatus(workId);
  } catch (error) {
    console.error('Error from AWSS3:', error);
    return error;
  }
};

export const cancelUpload = (workId: string) => {
  try {
    return AWS3Module.cancelUpload(workId);
  } catch (error) {
    console.error('Error from AWSS3:', error);
    return error;
  }
};