import { NativeModules } from 'react-native';

const { AWS3Module } = NativeModules;

export const uploadFile = (
  workId: string,
  filePath: string,
  s3Key: string,
  bucketName: string,
  accessKey: string,
  secreteKey: string,
  region: string
) => {
  try {
    return AWS3Module.uploadFileToS3(
      workId,
      filePath,
      bucketName,
      region,
      accessKey,
      secreteKey,
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