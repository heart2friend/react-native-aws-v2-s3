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
    console.log('workId', workId);

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
    console.error('Error from WorkManager:', error);
  }
};

export const getWorkStatus = async (workId: string) => {
  try {
    const status = await AWS3Module.getWorkStatus(workId);
    console.log('Work Status:', status);
    return status;
  } catch (error) {
    console.error('Failed to get work status:', error);
    return null;
  }
};
