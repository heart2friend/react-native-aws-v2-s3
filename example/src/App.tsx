import { useState, useEffect } from 'react';
import {
  StyleSheet,
  View,
  Text,
  Platform,
  Button,
  AppState,
} from 'react-native';
import RNFS from 'react-native-fs';
import Config from 'react-native-config';
import { uploadFile, getUploadStatus, cancelUpload, type AS3CredentialsType } from 'react-native-aws-s3';

export default function App() {
  const [appState, setAppState] = useState(AppState.currentState);
  const [workStatus, setWorkStatus] = useState('Unknown');

  useEffect(() => {
    const handleAppStateChange = async (nextAppState: any) => {
      if (appState.match(/inactive|background/) && nextAppState === 'active') {
        checkStatus();
      }
      setAppState(nextAppState);
    };

    const subscription = AppState.addEventListener(
      'change',
      handleAppStateChange
    );

    return () => {
      subscription.remove();
    };
  }, [appState]);

  useEffect(() => {
    checkStatus();
  }, []);

  const checkStatus = async () => {
    getUploadStatus('W10').then((result: any) => {
      const { workId, status } = result;
      console.log(`WorkId : ${workId} Status : ${status}`);
      setWorkStatus(status || 'Failed to fetch status');
    }).catch((error: any) => {
      setWorkStatus('Failed to fetch status');
      console.log(error);
    });
  };



  const uploadFileToS3 = async (workId: string, fileName: string) => {
    // Get the file path
    let filePath = '';

    if (Platform.OS === 'ios') {
      filePath = `${RNFS.MainBundlePath}/10MB-TESTFILE.ORG.pdf`;
    } else if (Platform.OS === 'android') {
      // Android: Copy the asset file to a temporary path first
      const destPath = `${RNFS.DocumentDirectoryPath}/10MB-TESTFILE.ORG.pdf`;
      await RNFS.copyFileAssets('10MB-TESTFILE.ORG.pdf', destPath); // Copy file from assets
      filePath = destPath;
    }

    const s3Key = Config.s3Key + fileName || '';

    const s3credentials: AS3CredentialsType = {
      bucketName: Config.bucketName || '',
      accessKey: Config.accessKey || '',
      secreteKey: Config.secreteKey || '',
      region: Config.region || '',
    }
   
    //Generic method for both iOS and Android
    uploadFile(
      workId,
      filePath,
      s3Key,
      s3credentials
    )
      .then((result: any) => {
        const { workId, status } = result;
        console.log(`WorkId : ${workId} Status : ${status}`);
      })
      .catch((error: any) => {
        console.log(error);
        console.log('Error Code:', error.code);
        console.log('Error Message:', error.message);
        console.log('User Info', error.userInfo);
      });
  };

  const upload = () => {
    uploadFileToS3('W1', '10MB-TESTFILE.ORG.1.pdf');

    // cancelUpload('W1');

    // uploadFileToS3('W2', '10MB-TESTFILE.ORG.2.pdf');

    // uploadFileToS3('W3', '10MB-TESTFILE.ORG.3.pdf');

    // uploadFileToS3('W4', '10MB-TESTFILE.ORG.4.pdf');

    // uploadFileToS3('W5', '10MB-TESTFILE.ORG.5.pdf');

    // uploadFileToS3('W6', '10MB-TESTFILE.ORG.6.pdf');

    // uploadFileToS3('W7', '10MB-TESTFILE.ORG.7.pdf');

    // uploadFileToS3('W8', '10MB-TESTFILE.ORG.8.pdf');

    // uploadFileToS3('W9', '10MB-TESTFILE.ORG.9.pdf');

    // uploadFileToS3('W10', '10MB-TESTFILE.ORG.10.pdf');

    // uploadFileToS3('W11', '10MB-TESTFILE.ORG.11.pdf');

    // uploadFileToS3('W12', '10MB-TESTFILE.ORG.12.pdf');

    // uploadFileToS3('W13', '10MB-TESTFILE.ORG.13.pdf');

    // uploadFileToS3('W14', '10MB-TESTFILE.ORG.14.pdf');

    // uploadFileToS3('W15', '10MB-TESTFILE.ORG.15.pdf');

    // uploadFileToS3('W16', '10MB-TESTFILE.ORG.16.pdf');

    // uploadFileToS3('W17', '10MB-TESTFILE.ORG.17.pdf');

    // uploadFileToS3('W18', '10MB-TESTFILE.ORG.18.pdf');

    // uploadFileToS3('W19', '10MB-TESTFILE.ORG.19.pdf');

    // uploadFileToS3('W20', '10MB-TESTFILE.ORG.20.pdf');
  };

  return (
    <View style={styles.container}>
      <Button onPress={upload} title="Upload" />
      <Text>Result: {workStatus}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
  },
});
