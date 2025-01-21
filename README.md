# react-native-aws-v2-s3

A lightweight React Native library for seamless file uploads to Amazon S3, supporting pre-signed URLs and AWS SDK integration.

Capable of uploading files to S3 in foreground, background and even app is closed in Android for iOS uploads file in foreground and background. 

## Installation

```sh
npm install react-native-aws-v2-s3
or 
yarn add react-native-aws-v2-s3
```

## Usage

```js
import { uploadFile, getUploadStatus, cancelUpload, type  AS3CredentialsType} from 'react-native-aws-v2-s3';

// ...

 //Generic method for both iOS and Android

     const s3credentials: AS3CredentialsType = {
      bucketName: '',
      accessKey:  '',
      secreteKey: '',
      region: '',
    }

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
```

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
